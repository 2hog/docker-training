layout: true
class: middle

---

# Running jobs on Kubernetes

--

[p.2hog.codes/running-jobs-on-kubernetes](https://p.2hog.codes/running-jobs-on-kubernetes)

---

# About 2hog.codes

* Founders of [SourceLair](https://www.sourcelair.com) online IDE + Dimitris Togias
* Docker and DevOps training and consulting

---

# Antonis Kalipetis

* Docker Captain and Docker Certified Associate
* Python lover and developer
* Technology lead at SourceLair / stolos.io
* Docker training and consulting

.footnote[[@akalipetis](https://twitter.com/akalipetis)]

---

# Paris Kasidiaris

* Python lover and developer
* CEO at SourceLair
* Docker training and consulting

.footnote[[@pariskasid](https://twitter.com/pariskasid)]

---

# Agenda

1. Workloads
2. Jobs
3. CronJobs

---

class: center

# Workloads

---

# Workloads

In a nutshell Workloads are:

1. Kubernetes controller objects
2. Containerized processes running in a Kubernetes cluster

---

# Workload types

Kubernetes has a few different Workload types in its arsenal:

1. Stateless applications
2. Stateful applications
3. Daemons
4. Batch jobs

---

# Stateless applications

Stateless applications are processes that do not store any state or data directly on persistent storage.

Examples of stateless applications are NGINX and Gunicorn.

Stateless application workloads can be deployed on Kubernetes with [Deployments](https://cloud.google.com/kubernetes-engine/docs/concepts/deployment).

---

# Stateful applications

Stateful applications are processes requiring that their state be stored on persistent storage.

Examples of stateful applications are PostgreSQL and MongoDB.

Stateful application workloads can be deployed on Kubernetes with [StatefulSets](https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/).

---

# Daemons

Daemons are processes performing ongoing background without the need for user intervention.

Examples of daemons include log collectors like Fluentd and monitoring services.

Daemon workloads can be deployed on Kubernetes with [DaemonSet](https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/)

---

# Batch jobs

Batch jobs represent finite, independent, and often parallel tasks which run to their completion.

Batch job workloads can be deployed on Kubernetes with [Jobs](https://cloud.google.com/kubernetes-engine/docs/how-to/jobs) and [CronJobs](https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/).

---

# Jobs

---

# Jobs

In Kubernetes Jobs are controller objects corresponding to Pods running to completion.

---

# Use cases

1. Email sending
2. File transconding
3. Background rendering

---

# Your first job

`steve-job.yml`:

```yml
apiVersion: batch/v1
kind: Job
metadata:
  name: steve
spec:
  template:
    spec:
      restartPolicy: OnFailure
      containers:
      - name: steve
        image: ubuntu:20.04
        command: ["echo",  "Hi, I am a long running process computing stuff."]
```

---

# Creating your first job

```console
$ kubectl apply -f steve-job.yml
job.batch/steve created
```

---

# Inspecting your first job

```console
$ kubectl describe job.batch/steve
Name:           steve

# ...truncated

  Containers:
   steve:
    Image:      ubuntu:20.04
    Port:       <none>
    Host Port:  <none>
    Command:
      echo
      Hi, I am a long running process computing stuff.
    Environment:  <none>
    Mounts:       <none>
  Volumes:        <none>
Events:
  Type    Reason            Age    From            Message
  ----    ------            ----   ----            -------
  Normal  SuccessfulCreate  9m26s  job-controller  Created pod: steve-fp4wz
  Normal  Completed         9m11s  job-controller  Job completed
```

---

# Viewing the logs of your first job

```console
$ export JOB_PODS=$(kubectl get pods --selector=job-name=steve --output=jsonpath={.items..metadata.name})
$ kubectl logs $JOB_PODS
Hi, I am a long running process computing stuff.
```

---

# Job parallelism

By default, Job Pods do not run in parallel.

The optional `parallelism` field specifies the maximum desired number of Pods a Job should run concurrently at any given time.

The actual number of Pods running might be less than the `parallelism` value if the remaining work is less than the `parallelism` value.

---

# Job completion count

A Job is completed when a specific number of Pods terminate successfully.

We can set a completion count by using the optional `completions` field.

The `completions` field specifies how many Pods should terminate successfully before the Job is complete.

The actual number of Pods running in parallel does not exceed the number of remaining completions.

---

# Parallel Job with completion count

`parallel-job.yml`:

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: parallel-job
spec:
  parallelism: 5
  completions: 2
  template:
    spec:
      containers:
        - name: parallel-job
          image: "ubuntu:20.04"
          command: ["echo",  "Hi, I am a long running process doing parallel stuff."]
      restartPolicy: Never
```

---

# Creating a parallel Job with completions

```console
$ kubectl apply -f parallel-job.yml
job.batch/parallel-job created
```

---

# Inspecting your parallel Job

```console
$ kubectl describe job.batch/parallel-job
Name:           parallel-job
Namespace:      default
Selector:       controller-uid=2e73d13b-0b67-4f2a-ab6d-29625e1a5467
Labels:         controller-uid=2e73d13b-0b67-4f2a-ab6d-29625e1a5467
                job-name=parallel-job
Annotations:    <none>
Parallelism:    5
Completions:    2

# ...truncated

Events:
  Type    Reason            Age   From            Message
  ----    ------            ----  ----            -------
  Normal  SuccessfulCreate  33s   job-controller  Created pod: parallel-job-j4pks
  Normal  SuccessfulCreate  33s   job-controller  Created pod: parallel-job-d8nn8
  Normal  Completed         30s   job-controller  Job completed
```

---

# Jobs with deadlines

By default, a Job creates new Pods forever if its Pods fail continuously.

To prevent this set a deadline value using the optional `activeDeadlineSeconds` field.

---

# Job with deadline

`deadline-job.yml`:

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: deadline-job
spec:
  activeDeadlineSeconds: 5
  template:
    spec:
      containers:
        - name: deadline-job
          image: "ubuntu:20.04"
          command: ["sleep",  "2", "&&", "exit", "1"]
      restartPolicy: Never
```

---

# Creating a Job with deadline

```console
$ kubectl apply -f deadline-job.yml
job.batch/deadline-job created
```

---

# Inspecting your Job with deadline

```console
$ kubectl describe job.batch/deadline-job
Name:                     deadline-job

# ...truncated

Events:
  Type     Reason            Age    From            Message
  ----     ------            ----   ----            -------
  Normal   SuccessfulCreate  4m32s  job-controller  Created pod: deadline-job-s5dzr
  Normal   SuccessfulCreate  4m31s  job-controller  Created pod: deadline-job-g5b5v
  Warning  DeadlineExceeded  4m27s  job-controller  Job was active longer than specified deadline
```

---

# Worst practices

1. Running closely-communicating parallel processes (e.g. scientific computing).
2. Using the `completions` field for a non-parallel Job.

---

# CronJobs

---

# CronJobs

CronJobs are Kubernetes objects that create Jobs on a time-based schedule.

A CronJob is like a crontab line; it runs a job on a given schedule, written in [Cron format](https://en.wikipedia.org/wiki/Cron).

---

# Cron format

```
# ┌───────────── minute (0 - 59)
# │ ┌───────────── hour (0 - 23)
# │ │ ┌───────────── day of the month (1 - 31)
# │ │ │ ┌───────────── month (1 - 12)
# │ │ │ │ ┌───────────── day of the week (0 - 6) (Sunday to Saturday;
# │ │ │ │ │                                   7 is also Sunday on some systems)
# │ │ │ │ │
# │ │ │ │ │
# * * * * * command to execute
```

---

# Use cases

1. Cleanups
2. Backups
3. Reporting

---

# Your first CronJob

`cron-job.yml`:

```yaml
apiVersion: batch/v1beta1
kind: CronJob
metadata:
  name: cron-job
spec:
  schedule: "*/1 * * * *"  # Every minute
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: cron-job
            image: ubuntu:20.04
            command: ["date"]
          restartPolicy: Never
```

---

# Creating a CronJob

```console
$ kubectl apply -f cron-job.yml
cronjob.batch/cron-job create
```

---

# Viewing the Jobs of your CronJob

```console
$ kubectl get job
NAME                  DESIRED   SUCCESSFUL   AGE
cron-job-1606682640   1         0            1m
cron-job-1606682700   1         0            5s
```

---

# Inspecting your CronJob

```console
$ kubectl describe cronjob.batch/cron-job
Name:                          cron-job

# ...truncated

Active Jobs:         <none>
Events:
  Type    Reason            Age   From                Message
  ----    ------            ----  ----                -------
  Normal  SuccessfulCreate  99s   cronjob-controller  Created job cron-job-1606682640
  Normal  SawCompletedJob   89s   cronjob-controller  Saw completed job: cron-job-1606682640, status: Complete
  Normal  SuccessfulCreate  39s   cronjob-controller  Created job cron-job-1606682700
  Normal  SawCompletedJob   29s   cronjob-controller  Saw completed job: cron-job-1606682700, status: Complete
```

---

# CronJob deadlines

It's possible to define a deadline for starting a Job created by a CronJob.

The `startingDeadlineSeconds` field does exactly that.

Missed CronJobs are considered failures.

---

# CronJob with deadline

```yaml
apiVersion: batch/v1beta1
kind: CronJob
metadata:
  name: cron-job-with-deadline
spec:
  schedule: "* */1 * * *"  # Every hour
  startingDeadlineSeconds: 3600
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: cron-job
            image: ubuntu:20.04
            command: ["date"]
          restartPolicy: Never
```

---

# Concurrency policies in CronJobs

CronJobs let you decide how to treat concurrent executions of their Jobs.

This is done via the `concurrencyPolicy` field, which accepts the following values:

- `Allow`: Allows concurrent Jobs. This is the default.
- `Forbid`: Forbids concurrent Jobs and skips the next run if the previous run hasn't finished yet.
- `Replace`: Cancels currently-running Job and replaces it with a new one.

---

# A CronJob with concurrency policy

```yaml
apiVersion: batch/v1beta1
kind: CronJob
metadata:
  name: cron-job-with-concurrency
spec:
  schedule: "* */1 * * *"
  concurrencyPolicy: Replace
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: cron-job
            image: ubuntu:20.04
            command: ["date"]
          restartPolicy: Never
```

---

# CronJob history limit

CronJobs by default keep their last 3 successful and 1 failed jobs.

This can be tweaked using the following fields:

1. `successfulJobsHistoryLimit` (default: `3`)
2. `failedJobsHistoryLimit` (default: `1`)

---

# A CronJob with history limits

```yaml
apiVersion: batch/v1beta1
kind: CronJob
metadata:
  name: cron-job-with-history
spec:
  schedule: "* */1 * * *"
  successfulJobsHistoryLimit: 12
  failedJobsHistoryLimit: 24
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: cron-job
            image: ubuntu:20.04
            command: ["date"]
          restartPolicy: Never
```

---

# Worst practices

1. Replacing Celery, Sidekiq etc. with CronJobs
2. Creating CronJobs without history limits

---

# Ask your most weird questions!

---

class: center

# Thanks!
