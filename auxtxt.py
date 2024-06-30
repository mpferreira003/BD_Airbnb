txt = """
listing_id	id_review	date	reviewer_id	reviewer_name	comments
"""

formatted = txt.replace('	',', ')
print("{"+formatted+"}")