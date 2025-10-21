# spark_patch.py
import sys
from packaging.version import Version

sys.modules['distutils.version'] = type(sys)('distutils.version')
sys.modules['distutils.version'].LooseVersion = Version