import 'dart:math';

class WeatherChatService {
  static const List<Map<String, String>> _knowledgeBase = [
    {
      'keywords': 'hello|hi|hey|good morning|good evening|greet',
      'response':
          '👋 Hello! I\'m your Weather Assistant. Ask me anything about the weather — forecasts, tips, or climate facts!',
    },
    {
      'keywords': 'rain|rainy|raining|drizzle|shower|wet',
      'response':
          '🌧️ Rain is on the way! Make sure to carry an umbrella. Rain occurs when water droplets in clouds become too heavy and fall to the ground. Fun fact: The smell of rain is called *petrichor*!',
    },
    {
      'keywords': 'sun|sunny|sunshine|clear|bright',
      'response':
          '☀️ Sunny skies ahead! Perfect weather for outdoor activities. Remember to apply sunscreen (SPF 30+) and stay hydrated. UV index can be high during peak hours (10am–4pm).',
    },
    {
      'keywords': 'snow|snowy|snowfall|blizzard|flurry|frost|freeze|frozen',
      'response':
          '❄️ Snow is in the forecast! Bundle up and watch for icy roads. Snowflakes form when water vapor freezes around tiny particles. No two snowflakes are exactly alike!',
    },
    {
      'keywords': 'cloud|cloudy|overcast|grey|gray',
      'response':
          '⛅ Cloudy conditions expected. Clouds are formed from water droplets or ice crystals suspended in the atmosphere. Overcast skies usually mean rain is approaching within 12–24 hours.',
    },
    {
      'keywords': 'wind|windy|breeze|storm|gale|hurricane|typhoon',
      'response':
          '💨 Windy weather alert! Wind is caused by differences in atmospheric pressure. Strong gusts can exceed 100 km/h during storms. Secure loose outdoor items and be cautious while driving.',
    },
    {
      'keywords': 'fog|foggy|mist|misty|haze|hazy|smog',
      'response':
          '🌫️ Foggy conditions reduce visibility. Drive slowly, use low-beam headlights, and keep extra distance from other vehicles. Fog typically clears by mid-morning as temperatures rise.',
    },
    {
      'keywords': 'thunder|lightning|thunderstorm|storm|bolt',
      'response':
          '⛈️ Thunderstorm warning! Stay indoors and away from windows. Avoid using electrical appliances. Lightning can travel at 270,000 km/h — never shelter under a tree during a storm!',
    },
    {
      'keywords': 'hot|heat|warm|temperature|humid|humidity|heatwave',
      'response':
          '🌡️ Hot and humid conditions! Stay cool by wearing light-colored, loose-fitting clothes. Drink at least 8–10 glasses of water. Avoid strenuous outdoor activity between 11am and 3pm.',
    },
    {
      'keywords': 'cold|cool|chilly|freezing|ice|winter',
      'response':
          '🧥 Cold weather tip: Layer your clothing — a base layer, insulating layer, and windproof outer layer. Keep extremities (hands, ears, feet) covered. Frostbite can occur within minutes in extreme cold.',
    },
    {
      'keywords': 'forecast|weather today|tomorrow|week|weekend|prediction',
      'response':
          '📅 While I can\'t access live forecasts right now, I recommend checking apps like Weather.com or AccuWeather for up-to-date 7-day forecasts in your area. Weather patterns change fast!',
    },
    {
      'keywords': 'climate|global warming|environment|carbon|greenhouse',
      'response':
          '🌍 Climate change is shifting global weather patterns — causing more extreme events like heatwaves, wildfires, and floods. Reducing carbon emissions and planting trees are key steps to help.',
    },
    {
      'keywords': 'tip|advice|suggest|recommendation|prepare|what should',
      'response':
          '💡 Weather Tips:\n\n• Always check the morning forecast before heading out\n• Keep an emergency kit with water, food & flashlight\n• Dress in layers for unpredictable weather\n• App recommendation: Weather Underground for hyper-local data',
    },
    {
      'keywords': 'uv|uv index|sunburn|protection|spf',
      'response':
          '🕶️ UV Index Guide:\n• 0–2: Low (No protection needed)\n• 3–5: Moderate (Wear sunscreen)\n• 6–7: High (Wear hat & sunglasses)\n• 8–10: Very High (Limit sun exposure)\n• 11+: Extreme (Stay indoors)',
    },
    {
      'keywords': 'rainbow|arc|spectrum|color|colour',
      'response':
          '🌈 Rainbows form when sunlight is refracted and reflected inside water droplets during or after rain. They appear in the opposite direction of the sun. The colors always follow ROYGBIV order!',
    },
  ];

  static final List<String> _defaultResponses = [
    '🌤️ Interesting question! Weather is a fascinating topic. Try asking about rain, sunshine, snow, wind, fog, or general weather tips!',
    '🌡️ I\'m your personal weather assistant! Ask me about any weather condition or phenomenon and I\'ll share helpful information.',
    '⛅ I didn\'t quite catch that. You can ask me about rain, sun, clouds, storms, temperature, humidity, UV index, or weather safety tips!',
    '🌀 Weather has so many aspects! Ask me about forecasts, weather preparation tips, or specific climate phenomena.',
  ];

  static final Random _random = Random();

  static Future<String> getResponse(String message) async {
    await Future.delayed(const Duration(milliseconds: 800));

    final lowerMessage = message.toLowerCase();

    for (final entry in _knowledgeBase) {
      final keywords = entry['keywords']!.split('|');
      for (final keyword in keywords) {
        if (lowerMessage.contains(keyword)) {
          return entry['response']!;
        }
      }
    }

    return _defaultResponses[_random.nextInt(_defaultResponses.length)];
  }
}
