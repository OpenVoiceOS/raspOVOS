import sdnotify
from hivemind_core.service import HiveMindService
from ovos_utils.log import LOG

n = sdnotify.SystemdNotifier()


def on_ready():
    n.notify('READY=1')
    LOG.info("hivemind-core service ready!")


def on_started():
    n.notify('STARTED=1')
    LOG.info("hivemind-core service started!")


def on_stopping():
    n.notify('STOPPING=1')
    LOG.info("hivemind-core is shutting down...")


def main():
    service = HiveMindService(
        started_hook=on_started,
        ready_hook=on_ready,
        stopping_hook=on_stopping)

    try:
        service.run()
    except Exception as e:
        LOG.error(f"hivemind-core encountered an error: {e}")
        n.notify(f'ERRNO=1')
        exit(1)


if __name__ == "__main__":
    main()
