---
title: Fluent builders with custom build logic in Java
# excerpt And Bob's your Uncle for object creation!
modified:
tags: [java, lombok, builders]
date: 2018-09-01
---

*I have a backlog of posts I've been deferring for the past year. Unfortunately with working at Amazon Payments I have not had the 
time I wanted to keep a steady stream of knowledge-sharing. I'll do better!*

Today we'll talk about builders. Very often in microservices where we adhere to the contracts and boundaries of each service, we have 
to make service calls in the form of RPC or REST. That is, with each service's separation of concerns, to perform a task, we have to make
an API call to the downstream service to get a unit of work done, or to perform a callback upstream to notify the calling service that
we have completed a task. 

## Build all the things!

What I want in a builder: 
1. Custom Logic for building the object
2. Less boilerplate (and DRY)
3. Abstraction of the construction of the data object from other data objects
4. Extensibility that doesn't leak too into the calling code (open-closed principle)
5. Minimal parameter passing by the calling code to build the object.
6. Force some fields to only be set by the builder (i.e calling code cannot explicitly set this value)
7. Fluency. That is no explicit 'get' and 'set' in the method prefix.

It goes without surprise that at Amazon we have *a lot* of microservices powering the entire ecosystem of products we have at hand. 
Microservices have allowed teams to be able to grow outwards at scale and speed up development (when done right) as opposed to a monolithic
service/codebase.[^1] 

In a perfect world, perhaps each microservice would have clearly defined contracts and a unified data-model that is shared across each
service would make the calling code clean and simple. Let's use an example, perhaps after our service completes a certain unit of work
we need to call a downstream service to notify that we are done with processing. Downstream services may vend a `builder` to create a 
`POST` call with the required parameters for this. 

We typically have to perform some form of message passing in the intended format to the downstream microservice. For example, you might have
a service whose responsibility is to keep a record of payment processing, or for accounting. 

## Lombok to the rescue

Lombok would be the tool of choice for this as it removes a lot of the verbosity of Java. Particularly [Lombok Builders](https://projectlombok.org/features/Builder). 
Suppose that we are provided/vended this builder, or that developers have written one for the ease of calling the downstream service. 

~~~java 
import lombok.Builder;
import lombok.NonNull;

@Builder
public class DownstreamServiceCall {
    @Builder.default private long creationDate = System.currentTimeMillis();
    @NonNull private String uuid; 
    @NonNull private String customerId; 
    @NonNull private DataObject dataObject; 
}
~~~

This example would also use Defaults, which would automatically populate the field of the user does not specify a `creationDate`.

The calling code would then be able to do something like this, assuming the class has some `transaction` (data object) to get these values.

~~~java 
DownstreamServiceCall request = DownstreamServiceCall.builder()
                                    .uuid(transaction.getUUID())
                                    .customerId(transaction.getCustomerID())
                                    .dataObject(transaction.getDataObject())
                                    .build();

// Yes, this is a little weird, but I've seen service clients that require passing in ID/Headers as a separate paramter.
webClient.post(request.getUUID(), request);
~~~

I'm really a big fan of Builder pattern also because they do not require the user to figure out how to instantiate the object they need,
and also abstracts the actual building of the request. *Not having to call the setters on everything under the sun* is kind of nice.
Also, **immutability** is always sexy. Lombok really is a god send, never realized it when I first discovered it in my college days.

## The Problem

However, the real world is never that simple. With enterprise services, very often these services will have a different data model or 
a different set of parameters required to be passed over. While microservices allow speed of development by independent teams and 
services are free to model their data according to their domain, what I've seen is that for legacy reasons, or in the interest 
of backwards-compatibility or to bridge the differences between each data model, there's always some extra code 
required to massage the data before the request is sent to the service. 

Since Lombok does not support custom builder logic, developers end up doing is something similar to this, as a 'one-off'.

**Note:** Consider that `Transaction` is actually a legacy data object, and (for lack of better name), `TransactionV2` is the improved data model.


~~~java
//Transform the transaction object to get the fields required
Transaction legacyTransaction = convertToLegacyTransaction(transactionV2);

//UUID patch for backwards compatibility
String patchedUUID = UUIDUtility.patchUUID(legacyTransaction.getUUID());

DownstreamServiceCall request = DownstreamServiceCall.builder()
                                .uuid(patchedUUID)
                                .customerId(legacyTransaction.getCustomerID())
                                .dataObject(legacyTransaction.getDataObject())
                                .build();

webClient.post(patchedUUID, request);
~~~

Developers end up making a private function like `convertToLegacyTransaction`, or move their code to some Utility class, or if they're feeling fancy, a Factory class to handle
the transmutation of this data object. Often times it is for the sole purpose of the `DownstreamService` and nothing else. 

This is alright until other upstream microservices also attempt to call this downstream service.
What I've seen happen is that developers end up duplicating code to avoid having a dependency on the package containing this
Utility or Factory class, or they have to pull in an entire depenedency just to use this factory class. Pretty soon the boundaries 
between each library/package is blurred, and we have all sorts of services using this code to make a call to the downstream service.
Then, when there's a new business requirement or the domain has shifted, there's going to be a lot of pain updating these calls to 
pass down a new flag or value. 

While Lombok is great for what it's designed to do, sometimes there's a need to have a custom Builder to abstract these changes away 
from the calling code. The downstream service can vend a specialized builder to handle `TransactionV2` data Objects, or to vend it 
as a separate library for users. 

## The Solution

Hence, to make your own custom builder, you might think you'll not be able to use Lombok and you'll have to write a lot of boilerplate
code, dying a little inside as you favor less code so you have less to maintain. A solution is discussed in the Lombok documentation specified and 
highlighted in this [stackOverflow](https://stackoverflow.com/questions/42379899/use-custom-setter-in-lomboks-builder) question, which is to define a skeleton for yourself.

The goal I wanted when refactoring code like this was to have a user just do something like this: 

~~~java
    DownstreamServiceCall request = DownstreamServiceCallBuilder.builder()
                                    .transactionV2(transactionV2).build();
    webClient.post(request.getUUID(), request);
~~~

I also want to leverage Lombok whenever possible.

Here's what I got after trying out various forms:

~~~java
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.NonNull;
import lombok.Setter;
import lombok.experimental.Accessors;


@Accessors(fluent = true)
@AllArgsConstructor(access = AccessLevel.PRIVATE)
public class DownstreamServiceCall {
    @Getter @NonNull private final String uuid;
    @Getter @NonNull private final long creationDate;
    @Getter @NonNull private final String customerId;
    @Getter @NonNull private final DataObject dataObject;

    private static final String DATE_MILLIS_PAD_FORMAT = "%014d";
    private static final String UUID_FORMAT = "%s.%d";
    
    @NoArgsConstructor(staticName = "builder")
    @Accessors(chain=true, fluent=true)
    public static final class Builder {
        //Only allow calling code to set some parameters. 
        @Setter @NonNull private TransactionV2 transactionV2;
        private String uuid;
        private long creationDate;
        
        public DownstreamServiceCall build() {
            this.uuid = patchUUID(transactionV2.getUUID());
            
            if (transactionV2.getCreationDate() == null) {
                this.creationDate = String.format(DATE_MILLIS_PAD_FORMAT, System.currentTimeMillis());
            }
            Transaction legacyTransaction = convertToLegacyTransaction(transactionV2);
            
            return new DownstreamServiceCall(uuid, creationDate, legacyTransaction.getCustomerID(), legacyTransaction.getDataObject());
        }
        
        private String patchUUID(String originalUUID) {
            //do any legacy/backwards compatible logic, even pass in any parameters you might need!
            String modifiedUUID = String.format(UUID_FORMAT, originalUUID, computeVersionNumber());
            return modifiedUUID;
        }
        
        private Transaction convertToLegacyTransaction(TransactionV2 transactionV2) {
            Transaction legacyTransaction;
            //do any transformation logic here
            return legacyTransaction;
        }
    }
}
~~~

With this, calling code will now be able to do just this:

~~~java
    DownstreamServiceCall request = DownstreamServiceCall.builder()
                                    .transactionV2(transactionV2)
                                    .build();
    webClient.post(request.uuid(), request);
~~~

## What did we achieve?

Essentially we made a wrapper class `DownstreamServiceCall` , and inside it a static `Builder` class that will:

- Handle the custom logic to construct an object
- Encapsulate any form of data massaging and kept validation inside the builder
- Allow for changes to this builder class to be hidden away from the calling code as long as you have the data required
- One single point of extension if the interface/contract of the DownstreamService changes
- Force calling code to use a builder, as the access level for the wrapper class is set to `private`
- Enforce that once a `DownstreamServiceCall` is instantiated, the values it carries *will never change* and can only be `get` not `set`. Yay `#Immutability`!
- Fluent builder, and Bob's your uncle![^2]

This ensures transformation logic is kept in sync and all calling code will not have duplicate logic of how to construct such an object. In the future, 
if we have `transactionV3` or another data source, we can just extend another builder for it. By setting this pattern, we ensure 
future attempts to hack around this pattern are subjugated. 

The initial versions I had forced me to do weird things like instantiate the inner class with `new DownstreamServiceCall.Builder` in the calling code,
then set the fields, before `build()`, as I did not use the `@NoArgsConstructor(staticName)` annotation. 
The annotation reduces the need for this boilerplate: 

~~~java
/**
 * @return an instance of the builder class.
*/
public static Builder builder() {
    return new Builder();
}
~~~

Of course, the example looks pretty simple and there may be other methods that accomplish the same goal, but for the internal use case
I had, I could extend this builder to do anything it needed to create a well formed call and bring convenience and immutability to 
the calling code. Regarding the extra lines of code, it really wasn't that much more when I merged all the data massaging logic into 
one class. 

Special thanks for Wouter Sieling for his guidance on this builder method. I thought I'd share it given I haven't seen an implementation 
that would fit my use-case when I was doing this a while back. Mainly I wanted fluency and to avoid developers from adding more custom
logic outside of this builder class to make a service call. 

Thanks for reading!

[^1]: There's a lot of good books I've been recommended on this, but I have not read any of them to recommend any. AWS does have a cliffnotes of why they're the de-facto [here](https://aws.amazon.com/microservices/) though!
[^2]: PS: For those that did not get the joke, "Bob's your uncle" because of the popular kid tv series, Bob the Builder. Get it?