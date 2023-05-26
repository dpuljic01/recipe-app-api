"""
Sample tests
"""
from django.test import SimpleTestCase

from app.calc import add


class CalcTest(SimpleTestCase):
    """Test the calc module"""

    def test_add_numbers(self):
        res = add(5, 6)
        self.assertEqual(res, 11)
