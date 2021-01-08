import os
import sys
import time
import urllib.request
import datetime
import requests
from bs4 import BeautifulSoup

"""
    Crawler Cs and En terms from Závazné terminology database.
"""


URL = 'https://isap.vlada.cz/dul/zavaznet.nsf/ca?OpenView&Start=1'
base_url = '/'.join(URL.split('/')[:-1]) + '/'

cs = open('cs.txt', 'w')
en = open('en.txt', 'w')


def internet_on():
    try:
        urllib.request.urlopen('http://216.58.192.142')
        return True
    except:
        return False


def get_words(web_url):

    while not internet_on():
        time.sleep(600)

    page_info = web_url.split('/')[-1]

    # Get Content.
    url = web_url
    html = requests.get(url)
    plain = html.text
    s = BeautifulSoup(plain, "html.parser")
    tables = s.find_all('table')
    pages = tables[-1]
    words_tab = tables[0]

    # Get rows.
    rows = words_tab.find_all('tr')

    for row in rows[1:]:
        columns = row.find_all('font')
        
        try:
            cs_column = columns[0].find('a')
            en_column = columns[2]
            cs.write(cs_column.contents[0] + '\n')
            en.write(en_column.contents[0] + '\n')
        except:
            print(columns)
    
    # Check next page.
    columns = pages.find_all('td')
    next_column = columns[-2]

    next_page = next_column.find('a')['href']

    if page_info != next_page:
        get_words(base_url + next_page)
    else:
        print("Final page.")
        print(page_info)
        print(next_page)


if __name__ == "__main__":
    get_words(URL)
