from dasbus.identifier import DBusServiceIdentifier
from dasbus.connection import SessionMessageBus
from dasbus.error import ErrorMapper, get_error_decorator, DBusError

LAYER_SHELL_NAMESPACE_NAME = "pyws"

REGISTER_NAMESPACE = ("org", "pyws", "server")

error_mapper = ErrorMapper()

SESSION_BUS = SessionMessageBus(
    error_mapper=error_mapper
)

dbus_error = get_error_decorator(error_mapper=error_mapper)

REGISTER = DBusServiceIdentifier(
    namespace=REGISTER_NAMESPACE,
    message_bus=SESSION_BUS
)


@dbus_error("InvalidArgs", REGISTER_NAMESPACE)
class InvalidArgs(DBusError):
    pass
