import base64

from cloudevents.http import CloudEvent
import functions_framework


# Triggered from a message on a Cloud Pub/Sub topic.
@functions_framework.cloud_event
def subscribe(cloud_event: CloudEvent) -> None:
    # Print out the data from Pub/Sub, to prove that it worked
    print(base64.b64decode(cloud_event.data["message"]["data"]).decode())