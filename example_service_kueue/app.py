import logging
import os
import tempfile
import time

from octue.resources import Datafile, Dataset

from example_service_kueue.submodule import do_something

logger = logging.getLogger(__name__)


def run(analysis):
    logger.info("Started example analysis.")
    do_something()

    sleep_time = 720
    logger.info("Sleeping for %d seconds...")
    time.sleep(sleep_time)
    logger.info("Finished sleeping!")

    analysis.output_values = [1, 2, 3, 4, 5]

    with tempfile.TemporaryDirectory() as temporary_directory:
        with Datafile(os.path.join(temporary_directory, "output.dat"), mode="w") as (datafile, f):
            f.write("This is some example service output.")

        analysis.output_manifest.datasets["example_dataset"] = Dataset(path=temporary_directory, files={datafile})
        analysis.finalise(upload_output_datasets_to=analysis.output_location)

    logger.info("Finished example analysis.")
