#!/usr/bin/python
import sys
def is_venv():
    return (hasattr(sys, 'real_prefix') or
            (hasattr(sys, 'base_prefix') and sys.base_prefix != sys.prefix))
print(f'Are we in a virtual environment?: {is_venv()}\n')
