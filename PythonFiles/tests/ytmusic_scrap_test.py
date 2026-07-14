import sys
import os

## YT Music does not work :(

sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))
import generic_scrapper as scrapper

scrap_config: str = """
{
	"url": ""
	"root": "//*[@id='lyrics-root']",
	"fields": {
		"result": "."
	}
}
"""



if __name__ == "__main__":
    print(scrapper.test(scrap_config))