# Urine Analyzer Application

A Flutter-based mobile application for real-time monitoring and analysis of urine test results.

## Features

- Real-time dashboard displaying latest test results
- Auto-refresh every 5 seconds
- Detailed biomarker information with normal ranges
- Trend prediction graphs for each biomarker
- Historical data tracking
- User-specific data management
- Cross-platform support (Android/iOS)

## Technical Stack

- **Frontend**: Flutter/Dart
- **Backend**: Flask (Python)
- **Database**: SQLite
- **Machine Learning**: scikit-learn for trend prediction

## Key Biomarkers Monitored

- Glucose
- pH
- Protein
- Blood
- Specific Gravity
- Bilirubin
- Urobilinogen
- Ketones
- Nitrite
- Leukocytes

## Setup Instructions

### Prerequisites

- Flutter SDK
- Python 3.x
- Flask
- SQLite
- Required Python packages:
  - flask
  - flask-cors
  - pandas
  - numpy
  - scikit-learn
  - matplotlib

### Backend Setup

1. Install Python dependencies:
```bash
pip install flask flask-cors pandas numpy scikit-learn matplotlib
```

2. Start the Flask server:
```bash
python app.py
```

### Frontend Setup

1. Install Flutter dependencies:
```bash
flutter pub get
```

2. Run the application:
```bash
flutter run
```

## API Endpoints

- `/lab_results` - GET latest test results
- `/history` - GET historical data
- `/predict/<biomarker>` - GET trend predictions
- `/submit_results` - POST new test results

## Configuration

- Update IP address in `settings_provider.dart` for server connection
- Configure database path in `app.py`
- Adjust prediction parameters in the prediction endpoint

## Security

- CORS enabled for cross-origin requests
- Input validation for all API endpoints
- Error handling and logging implemented

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.
