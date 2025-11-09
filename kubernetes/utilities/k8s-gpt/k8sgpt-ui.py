import streamlit as st
import subprocess
import json

st.set_page_config(page_title="K8sGPT Analyzer", layout="wide")
st.title("🧠 K8sGPT Visual Analyzer")

# Optional flags
namespace = st.text_input("Namespace (optional):", "")
explain = st.checkbox("Include explanation (--explain)", True)
output_format = "json"

# Run Analysis
if st.button("Run k8sgpt analyze"):
    with st.spinner("Running analysis..."):
        cmd = ["k8sgpt", "analyze", "--output", output_format]

        if explain:
            cmd.append("--explain")
        if namespace:
            cmd.extend(["--filter", f"namespace={namespace}"])

        try:
            result = subprocess.run(cmd, capture_output=True, text=True, check=True)
            analysis = json.loads(result.stdout)
            st.success("Analysis complete!")

            for issue in analysis.get("results", []):
                st.markdown("### 🔍 Issue in Resource: " + issue.get("name", "Unknown"))
                st.write("Kind:", issue.get("kind"))
                st.write("Namespace:", issue.get("namespace"))
                st.write("Reason:", issue.get("reason"))
                if "explanation" in issue:
                    st.markdown("**🧠 Explanation:**")
                    st.write(issue["explanation"])

        except subprocess.CalledProcessError as e:
            st.error("Failed to run k8sgpt analyze", e)
            st.text(e.stderr)

