# LocalServiceHub Image Assets

## Homepage Images

### Hero Section
- **Background**: Professional handyman working
  - URL: `https://images.unsplash.com/photo-1581578731548-c64695cc6952`
  - High-quality construction/repair scene

### Service Categories
All images are 400x400 optimized for quick loading:

1. **Plumbing**
   - URL: `https://images.unsplash.com/photo-1607472586893-edb57bdc0e39`
   - Professional plumber at work

2. **Electrical**
   - URL: `https://images.unsplash.com/photo-1621905251189-08b45d6a269e`
   - Electrician working on panel

3. **Cleaning**
   - URL: `https://images.unsplash.com/photo-1581578731548-c64695cc6952`
   - Professional cleaning service

4. **Painting**
   - URL: `https://images.unsplash.com/photo-1589939705384-5185137a7f0f`
   - Painter with roller

5. **Landscaping**
   - URL: `https://images.unsplash.com/photo-1558618666-fcd25c85cd64`
   - Garden maintenance

6. **Moving**
   - URL: `https://images.unsplash.com/photo-1600518464441-9154a4dea21b`
   - Professional movers

7. **Carpentry**
   - URL: `https://images.unsplash.com/photo-1504148455328-c376907d081c`
   - Carpenter working

8. **HVAC**
   - URL: `https://images.unsplash.com/photo-1621873495884-845a939892d7`
   - HVAC technician

### Featured Providers
Professional headshots for provider cards:

1. **Male Professional**
   - URL: `https://images.unsplash.com/photo-1560250097-0b93528c311a`
   - Business professional

2. **Female Professional**
   - URL: `https://images.unsplash.com/photo-1594744803329-e58b31de8bf5`
   - Professional woman

3. **Service Professional**
   - URL: `https://images.unsplash.com/photo-1527203561188-dae1bc1a417f`
   - Friendly service provider

## Service Default Images

When services don't have uploaded images, these defaults are used based on category:

```ruby
default_images = {
  "Plumbing" => "https://images.unsplash.com/photo-1607472586893-edb57bdc0e39",
  "Electrical" => "https://images.unsplash.com/photo-1621905251189-08b45d6a269e",
  "Cleaning" => "https://images.unsplash.com/photo-1581578731548-c64695cc6952",
  "Painting" => "https://images.unsplash.com/photo-1589939705384-5185137a7f0f",
  "Landscaping" => "https://images.unsplash.com/photo-1558618666-fcd25c85cd64",
  "Moving" => "https://images.unsplash.com/photo-1600518464441-9154a4dea21b",
  "Carpentry" => "https://images.unsplash.com/photo-1504148455328-c376907d081c",
  "HVAC" => "https://images.unsplash.com/photo-1621873495884-845a939892d7"
}
```

## Additional Service Images

For variety in service listings:

### Home Repair
- `https://images.unsplash.com/photo-1558618666-fcd25c85cd64`
- `https://images.unsplash.com/photo-1581094794329-c8112c0e3529`

### Professional Services
- `https://images.unsplash.com/photo-1521791136064-7986c2920216`
- `https://images.unsplash.com/photo-1556909114-f6e7ad7d3136`

### Emergency Services
- `https://images.unsplash.com/photo-1543169098-507e8df1c734`
- `https://images.unsplash.com/photo-1621905252189-08b45d6a269e`

## Provider Profile Images

For seed data and demos:

### Male Providers
- `https://images.unsplash.com/photo-1472099645785-5658abf4ff4e`
- `https://images.unsplash.com/photo-1506794778202-cad84cf45f1d`
- `https://images.unsplash.com/photo-1500648767791-00dcc994a43e`

### Female Providers
- `https://images.unsplash.com/photo-1438761681033-6461ffad8d80`
- `https://images.unsplash.com/photo-1534528741775-53994a69daeb`
- `https://images.unsplash.com/photo-1517841905240-472988babdf9`

## Best Practices

1. **Image Optimization**:
   - Use `?q=80&w=800&auto=format&fit=crop` for optimal quality/size
   - Lazy load images below the fold
   - Use responsive images with srcset

2. **Fallback Images**:
   - Always have a default image for each category
   - Use placeholder while loading
   - Handle broken image links gracefully

3. **User Uploads**:
   - Providers should upload real service photos
   - Limit file size to 5MB
   - Accept JPG, PNG, WebP formats
   - Auto-optimize on upload

## Image Requirements

### Service Images
- Minimum: 800x600px
- Aspect ratio: 4:3 or 16:9
- File size: < 5MB

### Profile Pictures
- Minimum: 400x400px
- Aspect ratio: 1:1 (square)
- File size: < 2MB

### Portfolio Images
- Minimum: 1200x800px
- Multiple images encouraged
- Show before/after when possible

## CDN Usage

All Unsplash images are served via their CDN with:
- Global distribution
- Automatic optimization
- Responsive sizing
- WebP format support

## Updating Images

To change any default image:
1. Find new image on Unsplash
2. Copy the URL
3. Add parameters: `?q=80&w=800&auto=format&fit=crop`
4. Update in respective view file

## Legal Note

All Unsplash images are free to use under the Unsplash License. No attribution required but appreciated.