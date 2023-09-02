from unittest.mock import patch

from psycopg2 import OperationalError as Psycopg2Error

from django.core.management import call_command
from django.db.utils import OperationalError
from django.test import SimpleTestCase


@patch("core.management.commands.wait_for_db.Command.check")
class CommandTests(SimpleTestCase):
    def test_wait_for_db_ready(self, mocked_check):
        mocked_check.return_value = True

        call_command('wait_for_db')
        mocked_check.assert_called_once_with(databases=['default'])

    @patch('time.sleep')  # to avoid actual sleep inside tests
    def test_wait_for_db_delay(self, mocked_sleep, mocked_check):
        # First two times raise Psycopg2Error
        # Next 3 times raise OperationalError and then OK
        mocked_check.side_effect = [Psycopg2Error] * 2 +\
                                   [OperationalError] * 3 +\
                                   [True]

        call_command('wait_for_db')
        self.assertEqual(mocked_check.call_count, 6)
        mocked_check.assert_called_with(databases=['default'])
