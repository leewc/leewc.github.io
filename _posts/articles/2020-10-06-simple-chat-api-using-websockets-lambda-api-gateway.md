---
title: Build a Simple Chat API on Websockets 
# excerpt Using AWS Lambda and API Gateway and wsclient
modified:
tags: [aws, lambda, websockets]
date: 2020-10-16
---

(*Post originally written on 2019-08-08, published only now because life happens..*) `¯\_(ツ)_/¯`

## Background

At work we have started a 'build applications series', in which devs can propose a new technology to learn, and for 2 hours bi-weekly/monthly, get together and build something together, hands on. This was one of those sessions, I took notes from this session done by my coworker Aatish Mandelecha, Principal Engineer at Amazon Payments. Since it contained nothing internal, decided to share it here as well.

Today we'll work with WebSockets. 
- Read more about it [in this blog post by AWS](https://aws.amazon.com/blogs/compute/announcing-websocket-apis-in-amazon-api-gateway/)
- If you're wondering *why* websockets? I highly encourage checking out this [Simple Diagram/StackOverflow Explanation of what WebSockets are](https://stackoverflow.com/questions/19169427/how-websockets-can-be-faster-than-a-simple-http-request)
  - TL;DR: Web sockets avoid the additional HTTP overhead and allow for much more responsive communication between the client and the server.
  
  
  
## What we'll build today: 
  
1. Implement a `connect` API that allows clients to connect to, using Lambda (serverless)
	- State is saved via DynamoDB, having each client connecting modelled as a `connectionId`.
2. Implement a `sendMessage` API that holds the logic of broadcasting the message sent by a client to all other connected clients, using (you guessed it) yet another Lambda.
2. Wire up AWS API Gateway to said Lambdas to allow clients to connect to and to send messages.
3. Connect to the API using a WebSocket client `wsclient`.
4. Post messages to the lambda, with the outcome being: Messages are broadcasted to all clients, like a chat room.
  
It goes without saying, you need an AWS Developer account. Free tier should be fine. Let's get started.
  
  
  
## API Creation w/ API Gateway and Implement $connect w/Lambda

> Here we’ll create a chat API, and implement the routes defined by API Gateway, starting with **`$connect`** 

1. Create a New API from API Gateway (My Chat API in blog). Keep Route Selection Expression as default: `$request.body.action`.
2. Open a new tab, from the AWS Console, go to Lambda.
3. Create a Lambda named `putConnectedClientToDDB`
4. Copy-paste the below code  (just does a DDB put call)
   ``` js
    var AWS = require("aws-sdk");
    AWS.config.update({ region: process.env.AWS_REGION });
    var DDB = new AWS.DynamoDB({ apiVersion: "2012-10-08" });
    
    exports.handler = function (event, context, callback) {
     var putParams = {
     TableName: process.env.TABLE_NAME,
     Item: {
     connectionId: { S: event.requestContext.connectionId }
     }
     };
    
     DDB.putItem(putParams, function (err) {
     callback(null, {
     statusCode: err ? 500 : 200,
     body: err ? "Failed to connect: " + JSON.stringify(err) : "Connected."
     });
     });
    };
```
6. Create an environment variable `TABLE_NAME` with the value as  `WebsocketConnection`.   
7. Go to DynamoDB → create a table with name: `WebsocketConnection`, primary key: `connectionId`
8. Go to Lambda, select your Lambda, scroll down to **`Execution role`.**
9. Attach the policy `AmazonDynamoDBFullAccess`
10. Perfect, now let’s do some manual integration test! 
11. Go back to Lambda, ‘Configure Test Event'
12. Create New Event, do not use the template, copy-paste a sample event below.
    ```json
    {
      "requestContext" : {
          "connectionId" : "testConnectionId"
      }
    }
	```
14. Click on Test Event. You should see the Execution output with: ‘succeed’. 
15. Go back to API Gateway, select your API, click on ‘$connect’ and click on ‘Integration Request’, now select your lambda function (type in' `putConnectedClientToDDB`).
16. Save. At this point you have `connect` implemented, which will handle state when websocket clients connect to your app.



## Implement `sendMessage` with ‘SendMessageToConnectedClient’ Lambda

> Next we need to implement `sendMessage`, an action we will define on API Gateway for clients to use.

1. Create new Lambda function, give it the above name, click **create.**
2. Copy-paste the code below.
3. *learning*: Notice how there’s an *await*, so the DDB scan function below will asynchronously scan DDB, while we wait for the response.
4. *learning*: Here you’ll see the secret sauce of the API Gateway Management API. Lambda code below performs a ‘postToConnection’. which abstracts all WebSocket implementation between API Gateway and the client. This code also prunes connections to clients that have disconnected/died.
   ```js
    const AWS = require('aws-sdk');
    
    const ddb = new AWS.DynamoDB.DocumentClient({ apiVersion: '2012-08-10' });
    
    const TABLE_NAME = process.env.TABLE_NAME;
    
    exports.handler = async (event, context) => {
      let connectionData;
      
      try {
        connectionData = await ddb.scan({ TableName: TABLE_NAME, ProjectionExpression: 'connectionId' }).promise();
      } catch (e) {
        return { statusCode: 500, body: e.stack };
      }
      
      const apigwManagementApi = new AWS.ApiGatewayManagementApi({
        apiVersion: '2018-11-29',
        endpoint: event.requestContext.domainName + '/' + event.requestContext.stage
      });
      
      const postData = JSON.parse(event.body).data;
      
      const postCalls = connectionData.Items.map(async ({ connectionId }) => {
        try {
          await apigwManagementApi.postToConnection({ ConnectionId: connectionId, Data: postData }).promise();
        } catch (e) {
          if (e.statusCode === 410) {
            console.log(`Found stale connection, deleting ${connectionId}`);
            await ddb.delete({ TableName: TABLE_NAME, Key: { connectionId } }).promise();
          } else {
            throw e;
          }
        }
      });
      
      try {
        await Promise.all(postCalls);
      } catch (e) {
        return { statusCode: 500, body: e.stack };
      }
    
      return { statusCode: 200, body: 'Data sent.' };
    };
```
6. Add `TABLE_NAME` parameter to your Lambda: `WebsocketConnection` (or whatever you used previously).
7. SAVE 💾.
8. Scroll down to ‘**Execution role’.**
9. Attach the policy `AmazonDynamoDBFullAccess`. This allows your Lambda to communicate with DynamoDB.
10. Since `sendMessageToConnectedClient` needs to talk to API Gateway, let's attach the policy as well:  `AmazonAPIGatewayInvokeFullAccess`
11. Next, let’s wire up the route.



## Building the Send Route:

> A send route will ensure out Lambda build in step 1 gets invoked whenever a client connects to the API endpoint.

1. Go to API gateway and select your Chat API. 
2. Under ‘New Route Key’ > type in `sendMessage`.
3. Under Lambda function, type in `sendMessageToConnectedClient`.
4. Save.
5. Since we haven’t built `$disconnect` and `$default`  routes, open those routes and do the following:
    1. Click on ‘Integration Request’ (it’s a title link)
    2. Select ‘**mock**’.
    3. Save.
6. Awesome. **Time to deploy your API Gateway. **



## Deploy your API.

1. Actions > Deploy API.
2. Create a `beta` stage (or whatever name you like), and fill in the blanks as required (...or just the stage name).
3. AWS will now take you to ‘Stages’ where you’ll see your ‘beta’ stage editor. 
    This will give you the WebSocket URL **and** Connection URL.
    Sample:
    - WebSocket URL: `wss://1tv3vum7ac.execute-api.us-west-2.amazonaws.com/beta`
    - Connection URL: `https://1tv3vum7ac.execute-api.us-west-2.amazonaws.com/beta/@connections`
4. Congrats. You’re now ready to use WebSockets!



## Fun time. (Testing)

1. (Install NPM if you haven’t already, we need a websocket client).
2. `npm install -g wscat`
3. Connect to your WebSocket:
    `wscat -c wss://<endpoint>.execute-api.us-west-2.amazonaws.com/beta`
4. Alternatively, if your setup isn’t working and you still want to have fun, connect to Aatish‘s instance
    `wscat -c  wss://2rhfrffadh.execute-api.us-east-2.amazonaws.com/beta`.
5. Copy-paste this sample message, it defines the action you want API gateway to route, and the ‘data’:
    `{"action": "sendMessage", "data" : "Ground Control to Major Tom"}`
6. You should see your read receipt, being an echo of the message! Yay.
7. Get a few other friends and connect to your API Gateway. ***You now have a simple chat room or broadcast***!

## Next steps

- Consider making the client or input more human-friendly (can the Lambda handle this?)
- How would we gracefully disconnect/implement disconnect? Can you return 'bye!' to the client?

## Errors and Miscellany.

1. If you get the below error:
    ```json
	{"message": "Forbidden", "connectionId":"eHrdFcnvvHcCE-w=", "requestId":"eHrjDEuVPHcFWMg="}
	```
    - Don’t worry, eventual consistency for policies can take awhile, wait 5 minutes and try again! 
2. If you can’t install wscat for some reason
    1. run `npm install`
    2.  `npm install -g npm`
	3. Here's the output:
	
	```bash
	Last login: Wed Aug  7 11:35:42 on ttys003
	(base) 186590dff953:~ awsUser$ npm install
	npm WARN saveError ENOENT: no such file or directory, open '/Users/awsUser/package.json'
	npm notice created a lockfile as package-lock.json. You should commit this file.
	npm WARN enoent ENOENT: no such file or directory, open '/Users/awsUser/package.json'
	npm WARN awsUser No description
	npm WARN awsUser No repository field.
	npm WARN awsUser No README data
	npm WARN awsUser No license field.

	up to date in 0.469s
	found 0 vulnerabilities



	   ╭───────────────────────────────────────────────────────────────╮
	   │                                                               │
	   │       New minor version of npm available! 6.4.1 → 6.8.0       │
	   │   Changelog: https://github.com/npm/cli/releases/tag/v6.8.0   │
	   │               Run npm install -g npm to update!               │
	   │                                                               │
	   ╰───────────────────────────────────────────────────────────────╯

	(base) 186590dff953:~ awsUser$ npm install -g npm
	/usr/local/bin/npm -> /usr/local/lib/node_modules/npm/bin/npm-cli.js
	/usr/local/bin/npx -> /usr/local/lib/node_modules/npm/bin/npx-cli.js
	+ npm@6.10.3
	added 61 packages from 18 contributors, removed 18 packages and updated 63 packages in 8.819s
	(base) 186590dff953:~ awsUser$ npm install wscat
	npm WARN saveError ENOENT: no such file or directory, open '/Users/awsUser/package.json'
	npm WARN enoent ENOENT: no such file or directory, open '/Users/awsUser/package.json'
	npm WARN awsUser No description
	npm WARN awsUser No repository field.
	npm WARN awsUser No README data
	npm WARN awsUser No license field.

	+ wscat@2.2.1
	added 6 packages from 5 contributors and audited 6 packages in 0.515s
	found 0 vulnerabilities

	(base) 186590dff953:~ awsUser$ npm install -g wscat
	/usr/local/bin/wscat -> /usr/local/lib/node_modules/wscat/bin/wscat
	+ wscat@2.2.1
	added 6 packages from 5 contributors in 0.372s
	(base) 186590dff953:~ awsUser$ wscat -c  wss://2rhfrffadh.execute-api.us-east-2.amazonaws.com/beta
	connected (press CTRL+C to quit)
	> 
	```





