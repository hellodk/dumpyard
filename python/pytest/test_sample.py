# content of test_sample.py
def func(x):
    return x + 1


def test_answer():
    assert func(3) == 5


def test_answer1():
    assert func(9) == 10
