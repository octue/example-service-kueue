import os
import time
import unittest
from unittest import TestCase

from octue.twined.cloud.events.replayer import EventReplayer
from octue.twined.cloud.pub_sub.bigquery import get_events
import octue.twined.exceptions
from octue.twined.resources import Child

EXAMPLE_SERVICE_SRUID = "octue/example-service-kueue:0.1.5"


@unittest.skipUnless(
    condition=os.getenv("RUN_DEPLOYMENT_TEST", "0").lower() == "1",
    reason="'RUN_DEPLOYMENT_TEST' environment variable is False or not present.",
)
class TestKueueDeployment(TestCase):
    child = Child(
        id=EXAMPLE_SERVICE_SRUID,
        backend={"name": "GCPPubSubBackend", "project_id": "octue-twined-services"},
        service_registries=[
            {
                "name": "Octue service registry",
                "endpoint": "https://europe-west9-octue-twined-services.cloudfunctions.net/main-octue-twined-service-registry",
            }
        ],
    )

    def test_forwards_exceptions_to_parent(self):
        """Test that exceptions raised in the (remote) responding service are forwarded to and raised by the asker."""
        with self.assertRaises(octue.twined.exceptions.InvalidValuesContents):
            self.child.ask(input_values={"invalid_input_data": "hello"})

    def test_synchronous_question(self):
        """Test that the Kueue example deployment works, providing a service that can be asked questions and send
        responses.
        """
        answer, _ = self.child.ask(input_values={"n_iterations": 3})

        # Check the output values.
        self.assertEqual(answer["output_values"], [1, 2, 3, 4, 5])

        # Check that the output dataset and its files can be accessed.
        with answer["output_manifest"].datasets["example_dataset"].files.one() as (datafile, f):
            self.assertEqual(f.read(), "This is some example service output.")

    def test_asynchronous_question(self):
        """Test asking an asynchronous question and retrieving the resulting events from the event store."""
        answer, question_uuid = self.child.ask(input_values={"n_iterations": 3}, asynchronous=True)
        self.assertIsNone(answer)

        # Wait for question to complete.
        time.sleep(90)

        events = get_events(
            table_id="octue_twined.service-events",
            question_uuid=question_uuid,
            exclude_kinds=["question"],
        )
        replayer = EventReplayer(validate_events=True)
        answer = replayer.handle_events(events)

        # Check the output values.
        self.assertEqual(list(answer["output_values"]), [1, 2, 3, 4, 5])

        with answer["output_manifest"].datasets["example_dataset"].files.one() as (datafile, f):
            self.assertEqual(f.read(), "This is some example service output.")
