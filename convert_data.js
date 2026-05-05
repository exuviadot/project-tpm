const fs = require('fs');
const path = require('path');

const inputPath = path.join(__dirname, 'export.geojson');
const outputPath = path.join(__dirname, 'backend', 'data', 'restaurants.json');

const rawData = fs.readFileSync(inputPath, 'utf-8');
const geojson = JSON.parse(rawData);

// Dummy names, images, menus
const cuisines = ['Jawa', 'Sunda', 'Padang', 'Western', 'Seafood', 'Chinese', 'Fast Food', 'Sate', 'Soto', 'Bakso', 'Nusantara', 'Semua'];
const images = [
  'https://images.unsplash.com/photo-1514933651103-005eec06c04b?w=500&q=80',
  'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=500&q=80',
  'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=500&q=80',
  'https://images.unsplash.com/photo-1550547660-d9450f859349?w=500&q=80',
  'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=500&q=80'
];

const weathers = ['Cocok saat Hujan', 'Cocok untuk Siang Hari yang Panas', 'Pas untuk Sore yang Santai', 'Sempurna di Malam Hari', 'Cocok Kapan Saja'];

const generateMenu = () => {
  const menus = [];
  const count = Math.floor(Math.random() * 5) + 3; // 3 to 7 items
  for (let i = 0; i < count; i++) {
    menus.push({
      item: `Menu Spesial ${i + 1}`,
      price: Math.floor(Math.random() * 8 + 2) * 10000 // 20k - 100k
    });
  }
  return menus;
};

// Filter out non-point features or calculate center for polygons
geojson.features = geojson.features.map((f, i) => {
  let lat, lng;
  if (f.geometry.type === 'Point') {
    lng = f.geometry.coordinates[0];
    lat = f.geometry.coordinates[1];
  } else if (f.geometry.type === 'Polygon') {
    lng = f.geometry.coordinates[0][0][0];
    lat = f.geometry.coordinates[0][0][1];
  } else {
    lng = 110.3695; // default center jogja
    lat = -7.7956;
  }
  
  // ensure we convert it to point for simpler usage
  f.geometry = {
    type: 'Point',
    coordinates: [lng, lat]
  };

  f.properties = {
    location_id: f.properties['@id'] || `loc_${i}`,
    name: f.properties.name || `Restoran ${i}`,
    rating: (Math.random() * 2 + 3).toFixed(1), // 3.0 - 5.0
    ranking: i + 1,
    description: f.properties.description || `Restoran terbaik yang menyajikan hidangan lezat dan suasana nyaman di kota Yogyakarta.`,
    cuisine: f.properties.cuisine || cuisines[Math.floor(Math.random() * cuisines.length)],
    address: f.properties['addr:full'] || f.properties['addr:street'] || `Jl. Malioboro No. ${i+1}, Yogyakarta`,
    opening_hours: f.properties.opening_hours || '09:00 - 21:00',
    image_url: images[Math.floor(Math.random() * images.length)],
    weather_suggestion: weathers[Math.floor(Math.random() * weathers.length)],
    amenity: 'restaurant',
    menu: generateMenu()
  };

  return f;
});

// Take only first 200 to keep it lightweight as per spec (200+ tempat makan)
geojson.features = geojson.features.slice(0, 250);

fs.writeFileSync(outputPath, JSON.stringify(geojson, null, 2));
console.log(`Successfully generated backend/data/restaurants.json with ${geojson.features.length} features.`);
