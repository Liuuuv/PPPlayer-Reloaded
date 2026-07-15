import sys
import os

## YT Music does not work :(

sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))
import generic_scrapper as scrapper

scrap_config: str = """
{
    "url": "https://music.youtube.com/playlist?list=OLAK5uy_lDyN1VI3OoUae9vaMJQOO8ATQ2Z0xsV0Q",
    "root": "//ytmusic-responsive-list-item-renderer",
    "fields": {
        "title": ".//yt-formatted-string[@class='title']/a/text()",
        "link": ".//yt-formatted-string[@class='title']/a/@href",
        "title_attribute": ".//yt-formatted-string[@class='title']/@title"
    }
}
"""



if __name__ == "__main__":
    print(scrapper.test(scrap_config))