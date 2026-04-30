const axios = require('axios');
const cheerio = require('cheerio');
const fs = require('fs');

const url = 'https://www.tripadvisor.com/Restaurants-g14782503-Yogyakarta_Yogyakarta_Region_Java.html';

async function scrapeData() {
    try {
        const { data } = await axios.get(url, {
            headers: {
                'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36'
            }
        });

        const $ = cheerio.load(data);
        const results = [];

        
    } catch (error) {

    }
}