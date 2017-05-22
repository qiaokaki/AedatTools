# -*- coding: utf-8 -*-

"""
ImportAedat
"""

reload(ImportAedatHeaders)
import ImportAedatHeaders
import ImportAedatDataVersion1or2
import ImportAedatDataVersion3

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
        if args['fileFormat'] < 3:
            return ImportAedatDataVersion1or2(args)
        else:
            return ImportAedatDataVersion3(args)
            