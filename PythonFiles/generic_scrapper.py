import sys
import json
from lxml import html


def clean_result(value):
    if isinstance(value, list):
        if len(value) == 0:
            return ""

        value = value[0]

    if hasattr(value, "xpath"):
        for br in value.xpath(".//br"):
            br.tail = "\n" + (br.tail or "")

        return value.text_content().strip()

    return str(value).strip()
    
    


def extract_field(element, xpath):
    try:
        result = element.xpath(xpath)
        return clean_result(result)

    except Exception:
        return ""


def scrape(page_html, config):
    tree = html.fromstring(page_html)

    results = []

    rows = tree.xpath(config["root"])

    for row in rows:
        item = {}

        for name, xpath in config["fields"].items():
            item[name] = extract_field(row, xpath)

        results.append(item)

    return results


def main():

    if len(sys.argv) < 3:
        print(json.dumps({
            "error": "Arguments manquants"
        }))
        return


    html_file = sys.argv[1]
    config_file = sys.argv[2]


    with open(html_file, "r", encoding="utf-8") as f:
        page = f.read()


    with open(config_file, "r", encoding="utf-8") as f:
        config = json.load(f)


    result = scrape(page, config)


    print(json.dumps(
        result
    ))

def test(): ## debug
    html_file = "C://Users/olivi/AppData/Roaming/Godot/app_userdata/PPPlayer-(4.6)/temp_page.html"
    config_file = "utanet_song_list.json"
    with open(html_file, "r", encoding="utf-8") as f:
        page = f.read()


    with open(config_file, "r", encoding="utf-8") as f:
        config = json.load(f)


    result = scrape(page, config)
    print("result", result)

if __name__ == "__main__":
    main()
    # test()
    



