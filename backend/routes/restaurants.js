const router = require('express').Router();
const data   = require('../data/restaurants.json');
const features = data.features;

// GET /api/restaurants — semua restoran
router.get('/', (req, res) => {
  const { cuisine, min_rating, max_price, lat, lng, radius } = req.query;
  let result = features;

  if (cuisine && cuisine !== 'Semua')    result = result.filter(f => f.properties.cuisine === cuisine);
  if (min_rating) result = result.filter(f => f.properties.rating >= parseFloat(min_rating));
  if (max_price)  result = result.filter(f =>
    f.properties.menu && f.properties.menu.some(m => m.price <= parseInt(max_price))
  );
  if (lat && lng && radius) {
    result = result.filter(f => {
      const d = haversine(parseFloat(lat), parseFloat(lng),
                          f.geometry.coordinates[1], f.geometry.coordinates[0]);
      return d <= parseFloat(radius);
    });
  }
  res.json({ type: 'FeatureCollection', features: result });
});

// GET /api/restaurants/:location_id — detail satu restoran
router.get('/:location_id', (req, res) => {
  const found = features.find(f => f.properties.location_id === req.params.location_id);
  if (!found) return res.status(404).json({ error: 'Not found' });
  res.json(found);
});

// Haversine formula
function haversine(lat1, lng1, lat2, lng2) {
  const R = 6371;
  const dLat = (lat2 - lat1) * Math.PI / 180;
  const dLng = (lng2 - lng1) * Math.PI / 180;
  const a = Math.sin(dLat/2)**2 +
            Math.cos(lat1*Math.PI/180) * Math.cos(lat2*Math.PI/180) * Math.sin(dLng/2)**2;
  return R * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
}

module.exports = router;
