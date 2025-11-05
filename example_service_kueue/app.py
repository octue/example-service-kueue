import json
import logging
import time

from octue.resources import Datafile, Dataset
from octue.twined.resources.example import calculate_fibonacci_sequence

from example_service_kueue.submodule import do_something

logger = logging.getLogger(__name__)


def run(analysis):
    logger.info("Started example analysis.")

    # Get your input values...
    n = analysis.input_values["n"]

    # Do your calculations here...
    sequence = calculate_fibonacci_sequence(n)
    do_something()
    time.sleep(2)

    # Return results by assigning output values...
    analysis.output_values = {"fibonacci": sequence}

    # If output values are too large, or custom/binary file outputs
    # are required, you can save them as Datafiles and add them to
    # the output manifest...
    with Datafile("fibonacci.json", mode="w") as (datafile, f):
        json.dump(analysis.output_values, f)

    analysis.output_manifest.datasets["example_dataset"] = Dataset(files={datafile})
    logger.info("Finished example analysis.")
