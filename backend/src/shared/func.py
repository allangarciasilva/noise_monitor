import logging
import os


def create_file_logger(filename: str):
    filename = os.path.abspath(filename)
    os.makedirs(os.path.dirname(filename), exist_ok=True)

    logger = logging.getLogger(filename)
    fh = logging.FileHandler(filename)

    logger.setLevel(logging.INFO)
    fh.setLevel(logging.INFO)

    logger.addHandler(fh)
    return logger
