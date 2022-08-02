/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./routes/*.html",
    "./public/*.html"
  ],
  theme: {
    extend: {
      fontFamily: {
        heading: ["Righteous", "Helvetica", "sans"],
        prose: ["Bitter",  "Georgia", "serif"]
      }
    },
  },
  plugins: [
    require("@tailwindcss/typography"),
    require("@tailwindcss/forms"),
  ],
}
