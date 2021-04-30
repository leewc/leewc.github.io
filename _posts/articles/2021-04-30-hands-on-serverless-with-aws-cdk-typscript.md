---
layout: post
title: Hands-on AWS CDK for Serverless
excerpt: Leverage AWS CDK to build a sample serverless app (using Node, TypeScript, Lambda, API Gateway)
modified:
categories: articles
comments: true
share: true
readtime: true
date: 2021-04-30
---

## Background

At work, we previously had 'build applications series', in which devs can propose a new technology to learn and innovate outside from daily project work (for example, [this past session](https://leewc.com/articles/simple-chat-api-using-websockets-lambda-api-gateway/)), it kind of died off as everyone worked remotely during COVID. An Amazon wide survey on the voice of the developers showed the organization I was on had a good chunk of developers that feel like they're not learning *new* technologies. I was then volunteering (or rather, volun-told) to take over the previous initiative and revamp it. We had a successful run on this session with over 90 devs as I livestreamed and livecoded with them for 2 hours on Feb 23 2021! A ton of work goes into planning these things, but since I took my own time and effort to come up with this course, I am attaching it on my personal website as well. Especially since it contains nothing internal, and mainly uses technology available to the public :)

## Goal

* Learn about CDK and internals
* Learn about AWS CLI
* Generate a sample CDK App and actually develop on it (APIGateway + Lambda)

## Final Product

* You'll have a full CDK app that deploys an AWS API Gateway and a Lambda that handles request/responses.
* You'll also have a full dev environment.

## Part 1: Setting up CDK and Dev Environment

## Start

(Note, the tutorial is focused on AWS Cloud9 as it's a consistent environment, but you can also use VS Code/IDE of choice as well, noting the difference in fetching AWS Credentials)


1. Login to AWS
2. Navigate to Cloud9 > 'Create Environment'
3. Fill in the name '**startupdevbox1**'
4. Get an instance type a step up from the default.
5. Accept defaults

### Install Required Tools

1. (Optional) Update: `sudo yum -y update && sudo yum update`
2. Check if NVM is installed `nvm --version` 
    * Otherwise: `curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.0/install.sh | bash`

1. Install latest `Node.js`: ~~`nvm install stable`~~
    1. Workaround: `nvm install 15.5` and then `nvm alias default 15.5`
    2. Why? This issue: [https://github.com/aws/aws-cdk/issues/12536](https://github.com/aws/aws-cdk/issues/12536)
2. Link the 'default' version of Node, so when you run 'node' you get that version: `nvm alias default stable`
3. Verify: `$ node --version` should output a version like `v15.8.0`
4. Install TypeScript. 
    * Why? TypeScript is the preferred language for interacting with CDK, as CDK is written in TypeScript. However, you are free to use your own language, thanks to an AWS open-source Library called [`jsii` that transpiles CDK SDK into other languages for use](https://github.com/aws/jsii). There have been some issues, so I'd recommend sticking to TypeScript.
    * Verify if it is installed with `tsc --version` (if installed, outputs a Version), otherwise, `npm install -g typescript`.
5. Install AWS CDK.
    * This is likely not installed, when you run `cdk --version`
    * `npm install -g aws-cdk`

## Code gen

1. Create the directory: `mkdir ~/environment/build-apps-cdk` 
2. Switch to the directory: `cd ~/environment/build-apps-cdk`
3. `cdk init sample-app --language typescript`


This creates the following files and subdirectories in the directory. (copy-pasted from: [here](https://docs.aws.amazon.com/cloud9/latest/user-guide/sample-cdk.html)).

* A hidden `.git` subdirectory and a hidden `.gitignore` file, which makes the project compatible with Git.
* A lib subdirectory, which includes a `build-apps-cdk-stack.ts` file. This file contains the code for your AWS CDK stack. This code is described in the next step in this procedure.
* A bin subdirectory, which includes a `build-apps-cdk.ts` file. This file contains the entry point for your AWS CDK app.
* A `node_modules` subdirectory, which contains supporting code packages that the app and stack can use as needed.
* A hidden `.npmignore` file, which lists the types of subdirectories and files that npm doesn't need when it builds the code.
* A `cdk.json` file, which contains information to make running the cdk command easier.
* A `package-lock.json` file, which contains information that npm can use to reduce possible build and run errors.
* A `package.json` file, which contains information to make running the npm command easier and with possibly fewer build and run errors.
* A `README.md` file, which lists useful commands you can run with npm and the AWS CDK.
* A `tsconfig.json` file, which contains information to make running the tsc command easier and with possibly fewer build and run errors.

**Questions** you may have:
1. Where is the entry point? `bin/build-apps-cdk.ts`
2. Where is the main stack? (`lib/build-apps-cdk-stack.ts` file)
3. What does `cdk synth` do?
    * Will display the CloudFormation template that your CDK App generates.
    * What's in `cdk.out`? [https://docs.aws.amazon.com/cdk/latest/guide/assets.html](https://docs.aws.amazon.com/cdk/latest/guide/assets.html)
    * How is this different from `npm run build`?

Continuing our tutorial: 
1. Make a change: go to `build-apps-cdk-stack.ts`, and under the Queue, try to add `fifo : "true"` under visibility timeout setting, SAVE (CMD+S) and watch `cdk synth` fail.
2. Try again: 
	```ts
		const queue = new sqs.Queue(this, 'BuildAppsCdkQueue', {
		  visibilityTimeout: cdk.Duration.seconds(300),
		  fifo: true
		});
	```


* Does it work now when you `cdk synth`?
    * Based on the `Invalid parameter: Invalid parameter: Endpoint Reason: FIFO SQS Queues can not be subscribed to standard SNS topics` error, can you try adding `fifo: true` to the topic properties? 
        * `const topic = new sns.Topic(this, 'BuildAppsCdkTopic', {fifo: true});`
        * (Based on the error, add a topic name): `BuildAppsCdkTopic`
* Notice how code completion happens as you type. This is available in VS Code as well.

## Deploy

The first time you deploy an AWS CDK app into an environment (account/region), you can install a "bootstrap stack". This stack includes resources that are used in the toolkit's operation. For example, the stack includes an S3 bucket that is used to store templates and assets during the deployment process.


### `cdk bootstrap`

Output: 
	```bash

	USER:~/environment/build-apps-cdk (master) $ cdk bootstrap
	   Bootstrapping environment aws://187029153513/us-west-2...
	CDKToolkit: creating CloudFormation changeset...
	[██████████████████████████████████████████████████████████] (3/3)

	Environment aws://187029153513/us-west-2 bootstrapped.

	```

You should see a progress bar and eventual success (like above).


* Question you might have: What? What about credentials?
    * Read this Cloud9 Doc: [https://docs.aws.amazon.com/cloud9/latest/user-guide/how-cloud9-with-iam.html#auth-and-access-control-temporary-managed-credentials](https://docs.aws.amazon.com/cloud9/latest/user-guide/how-cloud9-with-iam.html#auth-and-access-control-temporary-managed-credentials)
    * Otherwise, follow: [https://cdkworkshop.com/15-prerequisites/200-account.html](https://cdkworkshop.com/15-prerequisites/200-account.html) (essentially you'll fetch credentials and save them to your `~/.aws.credentials` or Windows: `%USERPROFILE%\.aws\credentials`)

### `cdk deploy`
* Running this command will deploy your code to AWS. (You should run it)

### CloudFormation Console

(Visit the console, look at the Bootstrap stack, and your BuildApplications stack)


### Test Sample App

We'll publish to the generated SNS topic, and also poll for a message in the queue. Here's the commands you'll run.


* `aws sns list-topics --output table --query 'Topics[*].TopicArn'*`

* *`aws sns publish --subject "Hello from the AWS CDK" --message "This is a message from the AWS CDK." --message-group-id "123" --message-deduplication-id "123" --topic-arn arn:aws:sns:us-west-2:187029153513:BuildAppsCdkTopic.fifo`*
    * *(Replace with your TopicArn, change the `message-deduplication-id` for a second message)
    * *If successful, the output of the publish command displays the MessageId value for the message that was published.*
    * List your queue:  
	*`*aws sqs list-queues --output table --query 'QueueUrls[`*`]'`
* Receive all messages:  `aws sqs receive-message --queue-url https://us-west-2.queue.amazonaws.com/187029153513/BuildAppsCdkStack-BuildAppsCdkQueue0C219837-1C4UUUSZ30WCQ.fifo --max-number-of-messages 10`

Nice. In case this is your first time working with SQS, note that â€˜receiving a message' does not delete it from the queue, which is why if you do not delete it from the queue, SQS blocks you from retrieving your next message (FIFO). We work around this by setting `-max-number-of-messages`. You can read AWS CLI docs about deleting messages. 

Fun tip: 

* Use `--output text` and then make a one-liner like below!
* `aws sqs receive-message --queue-url $(aws sqs list-queues --output table --query 'QueueUrls[*]' --output text)`

# Build

### Now the fun part starts.

It was indicated from the survey results that developers want to learn about serverless, so let's start with that today. We'll deploy a simple Lambda that runs a docker container.

1. Remove SQS queues from `lib/build-apps-cdk-stack.ts`. 

We'll be building a quick API that can be invoked from the internet to a Lambda, which returns a mock response.

* (NOTE to presenter: Talk about how manually clicking through API Gateway is a pain)
* To best develop on the CDK, I've found it useful to:
    * Google
    * Read CDK docs to get an idea of what you want.
        * [https://docs.aws.amazon.com/cdk/api/latest/docs/aws-apigatewayv2-readme.html](https://docs.aws.amazon.com/cdk/api/latest/docs/aws-apigatewayv2-readme.html)

### API Gateway

1. First we create an APIGateway. As much as the purist in me wants to avoid copy, it's really faster to look at some sample code and run with it :) 
    1. That being said, typing the code out is much more interesting to learn as you'll see the TypeScript language server work it's magic. 
    2. [https://docs.aws.amazon.com/cdk/api/latest/docs/aws-apigatewayv2-readme.html#defining-http-apis](https://docs.aws.amazon.com/cdk/api/latest/docs/aws-apigatewayv2-readme.html#defining-http-apis)
2. Looking at that reference above, we copy-pasta into your `build-apps-cdk-stack.ts`:
	```ts
	const httpApi = new HttpApi(stack, 'BuildApplications-20211-Api');

	httpApi.addRoutes({
	  path: '/books',
	  methods: [ HttpMethod.GET ],
	  integration: getBooksIntegration,
	});
	httpApi.addRoutes({
	  path: '/books',
	  methods: [ HttpMethod.ANY ],
	  integration: booksDefaultIntegration,
	});
	```

This essentially creates a new HttpApi, named HttpApi, with routes added to it. You'll notice from the docs I have not copied the integrations. Instead we'll use mock integrations. 

* You'll might notice the red swiggly lines indicating TypeScript has no idea what you just wrote. 
* That's because you need to install the dependency using the name on the top of the docs:
    * `npm install` `@aws-cdk/aws-apigatewayv2`
        * **This is required whenever you want to make use of a construct (more on constructs below).**
    * Add the import statement: `import { HttpApi, HttpMethod } from '@aws-cdk/aws-apigatewayv2'`
        * Side note, if you're interested in TypeScript's import syntax and the above â€˜barrel imports', see [this](https://stackoverflow.com/questions/38729486/typescript-difference-between-import-and-import-with-curly-braces)
    * Change the `stack` variable as well to `this`, since you're inside the stack.
    * At this point, only `integration` should have the red incorrect type as we don't have one yet. 

* Delete the `booksIntegration` we'll leave it empty for now

* Change the path to `/build`
* Adding an integration like above comes to mind next.

### Lambda

* Let's make a quick Lambda that will back this APIGateway. 
* Initial Steps are similar here https://cdkworkshop.com/20-typescript/30-hello-cdk/200-lambda.html
    * Create a `lambda` folder at the root (next to `bin` and `lib`
    * Create a `hello.js`  under `lambda` with simple handler code.
    * ```js 
          exports.handler = async function(event) {
          console.log("request:", JSON.stringify(event, undefined, 2));
          return {
            statusCode: 200,
            headers: { "Content-Type": "text/plain" },
            body: `Hello there from, CDK! You've hit [${event.requestContext.http.path}] from IP [${event.requestContext.http.sourceIp}]\n`
                + `Your user agent is [${event.requestContext.http.userAgent}]`
          };
        };
       ```
* `npm install @aws-cdk/aws-lambda`
    > *Make sure you do this in `~/environment/build-apps-cdk` or rather, where your CDK Node app lives (otherwise, it does nothing). You'll notice weird error in your IDE when you can't â€˜view definition'*
* Go back to your `build-apps-cdk-stack.ts` and add the following snippets of code:
    * `import * as lambda from '@aws-cdk/aws-lambda';`
        * **Note, there are 2 Lambda packages, the typical one above or**
        * `import * as lambda from '@aws-cdk/aws-lambda-nodejs';`
            * This one uses Docker containers behind the scene to build your NodeJS function (see deep dive section below)
    * (Hit save), then do the following:
    * ```js
    // defines an AWS Lambda resource
    const helloLambda = new lambda.Function(this, 'HelloHandler', {
			runtime: lambda.Runtime.NODEJS_12_X,    // execution environment
			code: lambda.Code.fromAsset('lambda'),  // code loaded from "lambda" directory
			handler: 'hello.handler'                // file is "hello", function is "handler"
    });
      ```

    * If you're using `aws-lambda-nodejs`
    *     const helloLambda = new lambda.NodejsFunction(this, 'HelloHandler', {
              entry: 'lambda/hello.js',
            });
* At this point you'll notice these â€˜Constructs' all have 3 similar function inputs:
    * https://cdkworkshop.com/20-typescript/30-hello-cdk/200-lambda.html#a-word-about-constructs-and-constructors

### Lambda Integration

*  `npm install @aws-cdk/aws-apigatewayv2-integrations`
    * Tip: You might be a little frustrated at having to switch tabs at this point, you can also just open the docs in your editor under `node_modules` now that it's part of your dependency: `/build-apps-cdk/node_modules/@aws-cdk/aws-apigatewayv2-integrations/README.md`
* Now as you try to code the lambda integration like so: 
* ```js
    const lambdaIntegration = new LambdaProxyIntegration({
          handler: helloLambda, //this will cause a red line
    });
    ````   

* You'll notice a type error, inspect it, how can you fix it?
* Hint: https://docs.aws.amazon.com/cdk/api/latest/docs/aws-lambda-nodejs-readme.html
* Turns out, you need *another* construct. 
* If you ran into issues with `this` and see an error like: 
* ````bash
     error TS2345: Argument of type 'this' is not assignable to parameter of type 'Construct'.
      Type 'BuildAppsCdkStack' is not assignable to type 'Construct'.
        Types of property 'node' are incompatible.
          Type 'import("/home/ec2-user/environment/build-apps-cdk/node_modules/@aws-cdk/core/lib/construct-compat").ConstructNode' is not assignable to type 'import("/home/ec2-user/environment/build-apps-cdk/node_modules/@aws-cdk/aws-lambda-nodejs/node_modules/@aws-cdk/core/lib/construct-compat").ConstructNode'.
            Types have separate declarations of a private property 'host'.
  ````
    * **Fix** `npm update` or, keep your dependencies in the same version: [https://github.com/aws/aws-cdk/issues/3416](https://github.com/aws/aws-cdk/issues/3416)
    * Basically, you need to [have your dependencies in the same version](https://stackoverflow.com/questions/22343224/whats-the-difference-between-tilde-and-caret-in-package-json)
    * ```json
    "dependencies": {
			"@aws-cdk/aws-apigatewayv2": "^1.88.0",
			"@aws-cdk/aws-apigatewayv2-integrations": "^1.88.0",
			"@aws-cdk/aws-lambda-nodejs": "^1.89.0", #the ^ and version number causes problems :(
			"@aws-cdk/aws-sns": "1.88.0",
			"@aws-cdk/aws-sns-subscriptions": "1.88.0",
			"@aws-cdk/aws-sqs": "1.88.0",
			"@aws-cdk/core": "1.88.0"
        }
        ```
    * On different version conflicts, [MonoCDK is the longer-term solution to this](https://www.npmjs.com/package/monocdk), but it is still under experimentation. 

## Checkpoint: This is what you should have at this point

* ```ts
	import * as cdk from '@aws-cdk/core';
    import * as lambda from '@aws-cdk/aws-lambda-nodejs';
    import { HttpApi, HttpMethod } from '@aws-cdk/aws-apigatewayv2';
    import { LambdaProxyIntegration } from '@aws-cdk/aws-apigatewayv2-integrations';
    
    export class BuildAppsCdkStack extends cdk.Stack {
      constructor(scope: cdk.App, id: string, props?: cdk.StackProps) {
        super(scope, id, props);
        
        const helloLambda = new lambda.NodejsFunction(this, 'HelloHandler', {
          entry: 'lambda/hello.js',
        });
        
        const lambdaIntegration = new LambdaProxyIntegration({
          handler: helloLambda,
        });
    
        const httpApi = new HttpApi(this, 'BuildApplications');
    
        httpApi.addRoutes({
          path: '/build',
          methods: [ HttpMethod.GET ],
          integration: lambdaIntegration
        });
        
        httpApi.addRoutes({
          path: '/build',
          methods: [ HttpMethod.ANY ],
          integration: lambdaIntegration,
        });
      }
    }
    ```

* Run `cdk diff` to see what changed
    * What does `cdk diff` actually show? Is it the actual state of the world? Or is it just the difference between the last deployed cloudformation template vs what you have currently? Why i
        * (It's the latter)
* What? No disk space left? Wtf? 
    * Resize your instance
    * It's 2021, but AWS Cloud9 only starts with 10gb of size, using Docker runtimes will cause this to be out of space. Let's resize: [following this guide](https://docs.aws.amazon.com/cloud9/latest/user-guide/move-environment.html#move-environment-resize)
    * `cd` back out into environment, upload/drag-n-drop your file in, run that comment below, and `cd` back into your CdkApp.
    * `bash resize.sh 16`
        `
* Try again!

### Some Deep Dive

* Node JS Lambda actually is a construct that uses Docker: [Dockerfile](https://github.com/aws/aws-cdk/blob/master/packages/%40aws-cdk/aws-lambda-nodejs/lib/Dockerfile) (See the README to understand more).

# Can I Move Even Faster?

**AWS Solutions Constructions** (experimental, out of the box patterns):

* [https://aws.amazon.com/blogs/aws/aws-solutions-constructs-a-library-of-architecture-patterns-for-the-aws-cdk/](https://aws.amazon.com/blogs/aws/aws-solutions-constructs-a-library-of-architecture-patterns-for-the-aws-cdk/)
* [https://docs.aws.amazon.com/solutions/latest/constructs/aws-apigateway-lambda.html](https://docs.aws.amazon.com/solutions/latest/constructs/aws-apigateway-lambda.html)

### Do-it-yourself

What's next? 

* Set up `CodeCommit` to store your code and `CodePipeline` to deploy your code ala Full CD?
    * [https://docs.aws.amazon.com/cdk/api/latest/docs/aws-codecommit-readme.html](https://docs.aws.amazon.com/cdk/api/latest/docs/aws-codecommit-readme.html)
* Double down on Lambda?
    * [https://dev.to/aws-heroes/deploying-a-ml-model-using-the-new-aws-lambda-container-image-functionality-4e7o](https://dev.to/aws-heroes/deploying-a-ml-model-using-the-new-aws-lambda-container-image-functionality-4e7o)

### Clean up (`#frugal`)

* `cdk destroy`

# Conclusion

You learnt how to develop with CDK, sample some of the pains of it as well, but in my opinion, beats writing YAML/CloudFormation and type-safety still avoids you from shooting yourself in the foot (sometimes). Oh, it also definitely beats using the AWS Console, sample screenshots: https://www.qloudx.com/mocking-rest-api-responses-in-amazon-api-gateway/

# Credits

References: 
* [https://docs.aws.amazon.com/cloud9/latest/user-guide/sample-cdk.html](https://docs.aws.amazon.com/cloud9/latest/user-guide/sample-cdk.html)
* [https://cdkworkshop.com/20-typescript/](https://cdkworkshop.com/20-typescript/)


# Questions asked during the session

* How does cdk synth check with whatever is already deployed in AWS?
   > It doesn't, it really just looks at your CDK code and generates a template based on that. 
   > `diff` compares with the last generated template.

PS: Please pardon any weird formatting issues, this was originally written in Quip, and then exported to markdown did not go smoothly and I had to manually lint and format it myself.