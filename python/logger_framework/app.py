import settings
import os
import logging
import sys

reload(sys)
sys.setdefaultencoding('utf8')

base_dir = settings.PATH
log_file_dir = settings.LOG_FILE_DIR
log_file = settings.LOG_FILE
directories_to_create = [log_file_dir]

logger = logging.getLogger(__name__)

# Creating the directories if not already exists
for directoy in directories_to_create:
    try:
        logger.info("Creating directory ", directoy)
        os.makedirs(directoy)
    except OSError as os_err:
        logger.error("Error while creating directory ", os_err)
        if not os.path.isdir(directoy):
            # If the directpory is already present
            logger.info("Directory %s already present" % directoy)

# Creating the file if not already exists
if not os.path.exists(log_file):
    logger.info("Creating the file", log_file)
    open('log_file', 'w').close()

# Specifying the log configurations
logger.info("All necessary required files and directories are created now")
logging.basicConfig(level=logging.INFO)
handler = logging.FileHandler(log_file)
handler.setLevel(logging.INFO)
formatter = logging.Formatter(
    '%(asctime)s - %(name)s - %(levelname)s - %(message)s')
handler.setFormatter(formatter)
logger.addHandler(handler)


def main():
    '''
    Main function
    '''
    logger.info("Directory check completed")
    logger.error("Command generated %s")
    logging.debug('This is a debug message')
    logging.info('This is an info message')
    logging.warning('This is a warning message')
    logging.error('This is an error message')
    logging.critical('This is a critical message')
#    logger.info("Sent acknowledgement for job_id %s %s" %(job_id, resp.content))
#    logger.info("Got all the required job list %s" % job_list)


if __name__ == "__main__":
    main()
