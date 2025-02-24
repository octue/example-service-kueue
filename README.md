# example-service-kueue

An example Octue Twined data service using Kubernetes/Kueue as the service backend.

The terraform modules this service depends on are:

- [Octue Twined core](https://github.com/octue/terraform-octue-twined-core)
- [Octue Twined cluster](https://github.com/octue/terraform-octue-twined-cluster)

## Usage

### Install the client

```shell
pip install octue
```

## Usage

### Authenticate with GCP

Download a key for a developer service account and set the `GOOGLE_APPLICATION_CREDENTIALS` environment variable:

```shell
export GOOGLE_APPLICATION_CREDENTIALS=/path/to/gcp-credentials.json
```

### Interact with the service

Run the following python code:

```python
from octue.resources import Child


# Point to the data service
child = Child(
    id="octue/example-service:0.1.0",
    backend={"name": "GCPPubSubBackend", "project_name": "octue-sdk-python"},
)

# Ask a question
answer, _ = child.ask(input_values={"n_iterations": 5}, timeout=3600)

# Access the output data
answer
```
