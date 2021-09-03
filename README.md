# Implement a BPMN Service Task in Camunda
The article contains a step-by-step guide on how to implement a BPMN Service Task in Camunda making use of a Spring Boot Application. A Service Task within Camunda is used to either invoke Java code or to place a work item within a topic for an external worker to retrieve asynchronously.

**Java Nibble Article:** [https://www.javanibble.com/implement-bpmn-service-task-in-camunda/](https://www.javanibble.com/implement-bpmn-service-task-in-camunda/)

## Pre-Requisites
The following is required to run the Spring Boot example:
* [curl](https://www.javanibble.com/how-to-install-curl-on-macos-using-homebrew/)
* jq
* [maven](https://www.javanibble.com/how-to-install-maven-on-macos-using-homebrew/)

## BPMN Service Task
Camunda provides two ways for a service task to invoke services, namely Invoking Java Code and External Tasks. The above
business process shows how to invoke services making use of several ways. The process engine invokes the java code
synchronously except for the external tasks, where the process engine creates a work item and places it within a topic.
External workers poll the process engine based on a topic and retrieve the work items.

Use Camunda Modeller to model the process. The process model composes of four service tasks:

![BPMN Service Task](https://www.javanibble.com/assets/images/posts/bpmn-service-task/bpmn-service-task.png)

* Retrieve Coffee Order: Is a `Service Task` using `Java Class` as implementation and `com.javanibble.camunda.examples.RetrieveCoffeeOrderDelegate` as the Java Class.
* Make Coffee: Is a `Service Task` using `Delegate Expressions` as implementation and value of `${makeCoffee}`.
* Pour Coffee in Cup: Is a `Service Task` using `Expression` as implementation and value of `${coffeeService.pourCoffee(execution)}`.
* Deliver Coffee Order: Is a `Service Task` using `External` as implementation and topic value of `deliverCoffeeOrder`.


## Compile & Run The Example
### 1. Compile the application
Use the following command to compile the Spring Boot application making use of maven:

```shell
$ mvn clean install
```

### 2. Run the application
After you have successfully built the Camunda BPM Spring Boot application, the compiled artifact can be found in the
target directory. Use the following command to start the Camunda BPM Spring Boot Application.

```shell
$ mvn spring-boot:run
```

### 3. Execute the example
After the application has started, run the following command in another terminal:

**Run the command: Start Process Instance**

The following command instantiates a new instance of the `order-coffee` process and pass the process variable called
`order` with a value of `Espresso` to the process engine as part of the request body.

```shell
$ ./start_process.sh
```
The script performs the following commands:
```shell
curl --location --silent --output --request POST 'http://localhost:8080/engine-rest/process-definition/key/order-coffee/start' --header 'Content-Type: application/json' --data-raw '{
     "variables": {
         "order": {
             "value": "Espresso",
             "type": "String"
        }
    }
}'
```
The following is the output to the console after running the above command.

![Console](https://www.javanibble.com/assets/images/posts/bpmn-service-task/console-camunda-bpmn-service-task.png)

**Run the command: External Task**

The following script is used to fetchAndLock the external task and then after 2 seconds, the external task is completed.

```shell
$ ./run_external_task.sh
```
The script performs the following commands:
```shell
echo "\nDeliver Coffee Order Task: Fetch & Lock External Task"
TASK_ID=$(curl --location --fail --silent --request POST 'http://localhost:8080/engine-rest/external-task/fetchAndLock' --header 'Content-Type: application/json' --data-raw '{"workerId":"aWorkerId","maxTasks":1,"usePriority":true,"topics":[{"topicName": "deliverCoffeeOrder","lockDuration": 10000,"variables": ["orderId"]}]}' | jq -r '.[0].id')

sleep 2
echo "\nDeliver Coffee Order Task: Complete External Task"
curl --location --fail --silent --request POST "http://localhost:8080/engine-rest/external-task/$TASK_ID/complete" --header 'Content-Type: application/json' --data-raw '{"workerId": "aWorkerId","variables":{},"localVariables":{}}'
```

## View Camunda Admin Console
To view the Camunda Admin Console, type the following url in your browser while the application is running. You will be prompted with the login screen.

* [http://localhost:8080/](http://localhost:8080/)

After you have typed the above URL in a browser while the application is running, you will be prompted with the login screen. Type the Username and Password you set within the application properties file.


## View the H2 Console
To view the H2 Console, type the following url in your browser while the application is running. You will be prompted with the login screen.

* [http://localhost:8080/h2-console](http://localhost:8080/h2-console)

After you have typed the above URL in a browser while the application is running, you will be prompted with the login screen. Press the connect button since there is no password specified.
