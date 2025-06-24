# save this as app.py
import streamlit as st
import json

# Load JSON data
with open("json_data") as f:
    data = json.load(f)

st.title("🔍 K8sGPT Analysis Results")

# Show metadata
st.subheader("Metadata")
st.json({
    "Provider": data.get("provider"),
    "Status": data.get("status"),
    "Problems Detected": data.get("problems")
})

# Show each result in an expandable section
st.subheader("Detailed Results")
results = data.get("results", [])
if not results:
    st.info("No results found.")
else:
    for idx, item in enumerate(results):
        with st.expander(f"Result {idx + 1}: {item.get('kind', 'Unknown')} - {item.get('name', 'Unnamed')}"):
            st.json(item)
