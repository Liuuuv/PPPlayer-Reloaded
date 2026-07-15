import requests
from bs4 import BeautifulSoup
import urllib.parse
import pyperclip

    
search_url = "https://music.youtube.com/browse/VLOLAK5uy_lDyN1VI3OoUae9vaMJQOO8ATQ2Z0xsV0Q"

try:
    headers = {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
        'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
        'Accept-Language': 'en-US,en;q=0.5',
    }
    
    # Faire la requête
    response = requests.get(search_url, headers=headers, timeout=10)
    response.raise_for_status()
    
    # Parser le HTML
    soup = BeautifulSoup(response.text, 'html.parser')
    
    text = soup.get_text()
    print(text)
    pyperclip.copy(text)
    
except Exception as e:
    print(f"Erreur lors de la recherche: {e}")
    