import os
import unittest
from unittest.mock import patch

from octue import Runner
from octue.cloud.emulators.cloud_storage import GoogleCloudStorageEmulatorTestResultModifier, mock_generate_signed_url
from octue.resources import Manifest


REPOSITORY_ROOT = os.path.dirname(os.path.dirname(__file__))
TWINE_PATH = os.path.join(REPOSITORY_ROOT, "twine.json")
TEST_BUCKET_NAME = "octue-sdk-python-test-bucket"


class TestApp(unittest.TestCase):
    test_result_modifier = GoogleCloudStorageEmulatorTestResultModifier(default_bucket_name=TEST_BUCKET_NAME)
    setattr(unittest.TestResult, "startTestRun", test_result_modifier.startTestRun)
    setattr(unittest.TestResult, "stopTestRun", test_result_modifier.stopTestRun)

    def test_app(self):
        """Test that the app takes in input in the correct format and returns an analysis with the correct output
        values.
        """
        runner = Runner(
            app_src=os.path.join(REPOSITORY_ROOT, "example_service_kueue"),
            twine=TWINE_PATH,
            # Output location is taken from the app configuration automatically in a service but not if `Runner` is used
            # by itself.
            output_location="gs://octue-sdk-python-test-bucket/example_output_datasets",
        )

        with patch("google.cloud.storage.blob.Blob.generate_signed_url", mock_generate_signed_url):
            with self.assertLogs() as logging_context:
                analysis = runner.run(input_values={"n_iterations": 3})

        # Check log messages from app and submodules are emitted.
        self.assertEqual(logging_context.records[1].name, "app")
        self.assertEqual(logging_context.records[2].name, "example_service_kueue.submodule")

        # Check the output values.
        self.assertEqual(analysis.output_values, [1, 2, 3, 4, 5])

        # Test that the signed URLs for the dataset and its files work and can be used to reinstantiate the output
        # manifest after serialisation.
        downloaded_output_manifest = Manifest.deserialise(analysis.output_manifest.to_primitive())

        # Check that the output dataset and its files can be accessed.
        with downloaded_output_manifest.datasets["example_dataset"].files.one() as (datafile, f):
            self.assertEqual(f.read(), "This is some example service output.")
