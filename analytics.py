# analytics_routes.py
from flask import Blueprint, request, jsonify
from flask_login import login_required
from datetime import datetime
from extensions import db  # Adjust based on where you defined db, User, etc.
from models import User, Product, ReferFeedback  # Adjust imports based on your project structure
import logging
# Define a new blueprint for analytics
analytics_bp = Blueprint('analytics', __name__)


@analytics_bp.route('/analytics/product_userwise', methods=['GET'])
@login_required
def product_userwise_report():
    logging.debug("Processing request for product_userwise_report")
    # Parse optional date range from query parameters
    start_date = request.args.get('start_date')
    end_date = request.args.get('end_date')

    # Base query
    query = db.session.query(
        User.username,
        Product.name.label("product_name"),
        ReferFeedback.score,
        ReferFeedback.category,
        ReferFeedback.timestamp
    ).join(ReferFeedback, User.id == ReferFeedback.conversation_id) \
        .join(Product, Product.id == ReferFeedback.conversation_id)

    # Apply date filtering if both dates are provided
    if start_date and end_date:
        try:
            start_date = datetime.strptime(start_date, '%Y-%m-%d')
            end_date = datetime.strptime(end_date, '%Y-%m-%d')
            query = query.filter(ReferFeedback.timestamp.between(start_date, end_date))
        except ValueError:
            logging.error("Invalid date format provided: start_date=%s, end_date=%s", start_date, end_date)
            return jsonify({"error": "Invalid date format. Use YYYY-MM-DD."}), 400

    # Execute query
    results = query.all()
    logging.debug("Query executed successfully. Number of records fetched: %d", len(results))


    report = [
        {
            "username": result.username,
            "product_name": result.product_name,
            "score": result.score,
            "category": result.category,
            "timestamp": result.timestamp.strftime('%Y-%m-%d %H:%M:%S')
        } for result in results
    ]
    logging.debug("Report generated with %d entries", len(report))
    return jsonify(report)
