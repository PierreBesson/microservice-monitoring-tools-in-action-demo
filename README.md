# JHipster Microservice Monitoring Demo

Slides available at: [https://pierrebesson.github.io/microservice-monitoring-tools-in-action-slides/](https://pierrebesson.github.io/microservice-monitoring-tools-in-action-slides/)

## Quick start

- Start the stack: `cd docker && docker-compose up -d`
- Scale the microservices: `docker-compose scale store-app=2 invoice-app=2`
- Start gatling performance tests: `./download-gatling.sh && ./run-gatling.sh`

## Architecture

![architecture](./jhipster-microservice-monitoring-architecture.png)

## Links

- Gateway : [http://localhost:8080/#/gateway](http://localhost:8080/#/gateway)
- Gateway API (load-balanced): [http://localhost:8080/#/docs](http://localhost:8080/#/docs)
- Registry: [http://localhost:8761/#/](http://localhost:8761/#/)
- Registry API (per instance access): [http://localhost:8761/#/docs]- (http://localhost:8761/#/docs)
- Registry metrics: [http://localhost:8761/#/jhi-metrics](http://localhost:8761/#/jhi-metrics)

- Kibana: [http://localhost:5601](http://localhost:5601)
- Logtrail: [http://localhost:5601/app/logtrail"](http://localhost:5601/app/logtrail#)
- Kibana log dashboard: [http://localhost:5601/app/kibana#/dashboard/d712f650-e0eb-11e7-9c68-0b9a0f0c183c](http://localhost:5601/app/kibana#/dashboard/d712f650-e0eb-11e7-9c68-0b9a0f0c183c?_g=(refreshInterval%3A('%24%24hashKey'%3A'object%3A4097'%2Cdisplay%3A'5%20seconds'%2Cpause%3A!f%2Csection%3A1%2Cvalue%3A5000)%2Ctime%3A(from%3Anow-1h%2Cmode%3Aquick%2Cto%3Anow)))
- Zipkin UI: [http://localhost:9411/zipkin/](http://localhost:9411/zipkin/)

## Navigating Kibana

- First locate the timepicker at the top right corner, it is the most thing to know how to use
- To save you trouble, we have prepared a **log dashboard** so use it !

- The discover view is very interesting but it will stay cluttered as long as you don't filter things by clicking the small (+) and (-) magnifying glass on values of interest or by using the "add a filter" button
- You also have pre-made dashboards for JVM, service metrics, load metrics, traces

## Custom Dashboard creation

- select the `metrics-*` index pattern
- add filter `metric_type=TIMER`
- search for `* -metric_name=com.codahale.metrics.*`
- Go to Visualize
- Aggregate a metric field with a certain aggregation type (eg. average)
    - metric_p99
    - metric_mean_rate
- Set X-Axis `date histogram bucket`
- Split the series using a `Terms` sub-aggregation

## Timeseries manipulation with Timelion

While not as good as Grafana and Prometheus which provide a more powerful query language, Kibana gives access to Timelion which let's you graph and do mathematical operation (derivatives, divisions, etc.) on timeseries data.

### Example query

JVM Memory ratio
```
.es(q='jvm.memory.total.used', metric='avg:metric_value', split='instance_name.keyword:10') 
.divide(.es(q='jvm.memory.total.max', metric='avg:metric_value'))
.title('JVM Memory Ratio  (memory used / memory max)')
```

### Graph your own

- Find a metric in the discover view by searching for `com.mycompany.myapp.web.rest.CustomerResource.getAllCustomers`
- Deduce exploitable metrics:
    - metric_mean / metric_median
    - metric_min / metric_p75 / metric_p99 / metric_max

```
.es(q='com.mycompany.myapp.web.rest.CustomerResource.getAllCustomers', metric='avg:metric_min', split='instance_id.keyword:1'),
.es(q='com.mycompany.myapp.web.rest.CustomerResource.getAllCustomers', metric='avg:metric_median', split='instance_id.keyword:1', ),
.es(q='com.mycompany.myapp.web.rest.CustomerResource.getAllCustomers', metric='avg:metric_mean', split='instance_id.keyword:1', ),
.es(q='com.mycompany.myapp.web.rest.CustomerResource.getAllCustomers', metric='avg:metric_p75', split='instance_id.keyword:1'),
.es(q='com.mycompany.myapp.web.rest.CustomerResource.getAllCustomers', metric='avg:metric_p99', split='instance_id.keyword:1'),
.es(q='com.mycompany.myapp.web.rest.CustomerResource.getAllCustomers', metric='avg:metric_max', split='instance_id.keyword:1')
```

Graph the mean rate of a a timer : 
```
.es(q='com.mycompany.myapp.web.rest.CustomerResource.getAllCustomers', metric='avg:metric_mean_rate', split='instance_name.keyword:10')
.title('getAllCustomers mean rate in events/second')
```

And the derivative by adding `.derivative()` at the end of the query
```
.es(q='com.mycompany.myapp.web.rest.CustomerResource.getAllCustomers', metric='avg:metric_mean_rate', split='instance_name.keyword:10')
.derivatinve
.title('getAllCustomers mean rate derivative')
```

## Distributed tracing with Zipkin and Kibana

- Find a trace ID in your logs.
- Select it with (+), reset your query to * and order logs by oldest first
- You are now following logs accross service calls !
- Automate this by adding a Kibana field formatter in the X-B3-Trace-Id column
- Copy this ID and paste it in Zipkin UI to see the distribution graph
- Get back to Kibana from the Zipkin UI trace view by clicking on the *Logs* button
- Be aware that zipkin sorting works only on the traces already loaded by the query and is not a "full" search
- You can also access Zipkin data in Kibana by searching in the traces-* index

Thank you for joining us in our monitoring adventures !
