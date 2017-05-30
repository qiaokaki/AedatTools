# -*- coding: utf-8 -*-

"""
ImportAedat

Code contributions from Bodo Rueckhauser
"""

from PyAedatTools.ImportAedatHeaders import ImportAedatHeaders
from PyAedatTools.ImportAedatDataVersion1or2 import ImportAedatDataVersion1or2
#from PyAedatTools.ImportAedatDataVersion3 import ImportAedatDataVersion3

def ImportAedat(args):
    """
    Parameters
    ----------
    args :

    Returns
    -------
    """

# To handle: missing args; search for file to open - request to user

    with open(args['filePath'], 'rb') as args['fileHandle']:
        args = ImportAedatHeaders(args)
        if args['fileFormat'] < 3:
            return ImportAedatDataVersion1or2(args)
        else:
            return ImportAedatDataVersion3(args)
 