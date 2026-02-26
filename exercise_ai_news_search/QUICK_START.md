# Quick Start Guide - AI News Search App

## What Was Created

A fully functional single-screen news app with infinite scrolling pagination built in Flutter.

## Files Created

### Data Models
- **lib/models/news_article.dart** - NewsArticle data model with JSON serialization

### Services
- **lib/services/news_service.dart** - Handles API calls with pagination, mock data included

### Widgets
- **lib/widgets/news_card.dart** - Reusable news article card component

### Screens
- **lib/screens/news_list_screen.dart** - Main screen with paginated list view

### Updated Files
- **lib/main.dart** - App entry point
- **pubspec.yaml** - Added dependencies (http, intl, url_launcher)

## How the Pagination Works

1. **Initial Load**: Fetches the first page of news articles (10 items)
2. **Scroll Detection**: Uses ScrollController to detect when user scrolls to bottom
3. **Auto Load**: When bottom is reached, automatically fetches the next page
4. **Append Data**: New articles are appended to the existing list
5. **Loading Indicator**: Shows a loading spinner while fetching more data
6. **End Detection**: Stops loading when all available articles have been fetched

## Features Implemented

✅ Paginated list view with infinite scrolling  
✅ Beautiful card-based UI for each article  
✅ Article thumbnail images with error fallback  
✅ Source icon, name, and author information  
✅ Formatted publication dates  
✅ Open articles in external browser  
✅ Pull-to-refresh functionality  
✅ Error handling and retry mechanism  
✅ Loading states and animations  
✅ Responsive design  

## How to Run

```bash
# Get dependencies
flutter pub get

# Run the app
flutter run

# Run on specific device
flutter run -d <device-id>

# Run in release mode
flutter run --release
```

## Customization

### Change Number of Articles Per Page
Edit `lib/services/news_service.dart`:
```dart
static const int _itemsPerPage = 10; // Change to desired number
```

### Add More Mock Data
Edit the `_mockNewsData` list in `lib/services/news_service.dart` to add more articles.

### Connect to Real API
In `lib/screens/news_list_screen.dart`, modify the `_loadNews()` method:
```dart
Future<void> _loadNews() async {
  // Replace with your actual API endpoint
  const String apiUrl = 'https://your-api-endpoint.com/news';
  final news = await _newsService.fetchNewsFromUrl(apiUrl, page: _currentPage);
  // ... rest of the code
}
```

### Customize Styling
- Modify colors in `lib/main.dart` (colorScheme)
- Adjust card styling in `lib/widgets/news_card.dart`
- Change spacing and padding values in the widget files

## API Response Format Used

The app expects articles in this format:
```json
{
  "position": 1,
  "title": "Article Title",
  "source": {
    "name": "Source Name",
    "icon": "https://...",
    "authors": ["Author"]
  },
  "link": "https://...",
  "thumbnail": "https://...",
  "iso_date": "2026-01-02T15:30:13Z"
}
```

## Project Structure

```
lib/
├── main.dart
├── models/
│   └── news_article.dart
├── services/
│   └── news_service.dart
├── screens/
│   └── news_list_screen.dart
└── widgets/
    └── news_card.dart
```

## Testing

The app includes 12 mock news articles for testing pagination. Scroll to the bottom to see pagination in action.

## Key Classes

### NewsArticle (Model)
- Represents a single news article
- Handles JSON serialization/deserialization
- Used fields: position, title, sourceName, sourceIcon, authors, link, thumbnail, isoDate

### NewsService (Service)
- Fetches articles from API or mock data
- Implements pagination logic
- Methods: fetchNews(page), fetchNewsFromUrl(url, page), getTotalPages()

### NewsCard (Widget)
- Displays individual article information
- Shows thumbnail, title, source, author, and date
- Handles image loading errors

### NewsListScreen (Screen)
- Main screen displaying paginated list of articles
- Implements infinite scrolling
- Handles loading, error, and refresh states

## Troubleshooting

**No articles appearing?**
- Check internet connection (if using real API)
- Verify API endpoint and authentication
- Check browser console/logcat for errors

**Images not loading?**
- Ensure image URLs are valid and accessible
- Check network permissions (especially on Android)
- The app has fallback icon for missing images

**Pagination not working?**
- Verify scroll controller is properly attached to ListView
- Check that _itemsPerPage matches your API pagination size
- Ensure API returns correct number of items per page

## Dependencies

- **flutter**: Flutter SDK
- **cupertino_icons**: iOS style icons
- **http**: HTTP client for API calls
- **intl**: Date and number formatting
- **url_launcher**: Open URLs in browser

## Notes

- Mock data is included for immediate testing
- The app uses async/await for smooth performance
- Images are cached automatically by Flutter
- All errors are handled gracefully with user-friendly messages

