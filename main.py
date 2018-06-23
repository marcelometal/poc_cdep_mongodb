# -*- coding: utf-8 -*-
#
# Copyright (c) 2018, Marcelo Jorge Vieira <metal@alucinados.com>
#
#  This program is free software: you can redistribute it and/or modify
#  it under the terms of the GNU Affero General Public License as
#  published by the Free Software Foundation, either version 3 of the
#  License, or (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU Affero General Public License for more details.
#
#  You should have received a copy of the GNU Affero General Public License
#  along with this program.  If not, see <http://www.gnu.org/licenses/>.

import logging
import os
from dateutil import parser

from lxml.etree import iterparse
from pymongo import MongoClient


FILES_DIR = 'data'
FILES = ['AnoAtual.xml', 'AnoAnterior.xml', 'AnosAnteriores.xml']
# FILES = ['AnoAtual.xml']

OBJECT_LIST_MAXIMUM_COUNTER = 5000


def cleanup_element(elem):
    elem.clear()
    while elem.getprevious() is not None:
        del elem.getparent()[0]


def parse_str(tag, text):
    if not text:
        return None
    elif tag == 'txtNumero':
        return u'{}'.format(text)
    elif tag == 'datEmissao':
        return parser.parse(text).isoformat()
    else:
        try:
            return float(text)
        except:
            return text


def main():
    FORMAT='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
    logging.basicConfig(format=FORMAT, level=logging.INFO)

    client = MongoClient('localhost', 27017)
    db = client['poc_cdep']
    collection = db.poc_cdep_collection

    # Remove DB
    db.poc_cdep_collection.remove({})

    for filename in FILES:
        file_name = os.path.join(FILES_DIR, filename)
        context = iterparse(file_name, events=('start', 'end'))
        context = iter(context)
        actions = []
        for event, elem in context:
            if event != 'end' or elem.tag != 'DESPESA':
                continue
            data = {}
            for item in elem.getchildren():
                data[item.tag] = parse_str(item.tag, item.text)
            actions.append(data)

            # lxml leak
            cleanup_element(elem)

            if len(actions) == OBJECT_LIST_MAXIMUM_COUNTER:
                collection.insert_many(actions)
                logging.info(
                    'Added {0} items'.format(OBJECT_LIST_MAXIMUM_COUNTER)
                )
                actions = []
        if actions:
            collection.insert_many(actions)
            logging.info(
                'Added {0} items'.format(OBJECT_LIST_MAXIMUM_COUNTER)
            )
            actions = []


if __name__ == '__main__':
    main()
