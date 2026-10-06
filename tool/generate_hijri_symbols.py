"""Generate/check pinned Hijri data without replacing license notices."""
import sys
from generate_calendar_data import main

if __name__ == '__main__':
    main(['--calendar', 'hijri', *sys.argv[1:]])
