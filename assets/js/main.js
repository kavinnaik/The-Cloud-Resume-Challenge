// Set current year in footer
document.addEventListener("DOMContentLoaded", () => {
  const yearEl = document.getElementById("year");
  if (yearEl) {
    yearEl.textContent = new Date().getFullYear().toString();
  }
});

// Mobile navigation toggle
const nav = document.querySelector(".nav");
const navToggle = document.querySelector(".nav-toggle");

if (nav && navToggle) {
  navToggle.addEventListener("click", () => {
    const isOpen = nav.classList.toggle("open");
    navToggle.setAttribute("aria-expanded", String(isOpen));
  });

  nav.querySelectorAll("a[href^='#']").forEach((link) => {
    link.addEventListener("click", () => {
      if (nav.classList.contains("open")) {
        nav.classList.remove("open");
        navToggle.setAttribute("aria-expanded", "false");
      }
    });
  });
}

// Scroll reveal animations
const revealEls = document.querySelectorAll(".reveal");

if ("IntersectionObserver" in window) {
  const observer = new IntersectionObserver(
    (entries) => {
      entries.forEach((entry) => {
        if (entry.isIntersecting) {
          entry.target.classList.add("in-view");
          observer.unobserve(entry.target);
        }
      });
    },
    {
      threshold: 0.18,
    }
  );

  revealEls.forEach((el) => observer.observe(el));
} else {
  // Fallback for older browsers
  revealEls.forEach((el) => el.classList.add("in-view"));
}

// Visitor counter
async function fetchVisitorCount() {
  const counterEl = document.getElementById("visitor-count");
  if (!counterEl) return;

  // Replace with your deployed API Gateway invoke URL
  const apiEndpoint = window.VISITOR_COUNT_API_URL || "";

  if (!apiEndpoint) {
    // Leave placeholder in place if not configured yet
    return;
  }

  try {
    const response = await fetch(apiEndpoint, {
      method: "GET",
      headers: {
        "Content-Type": "application/json",
      },
    });

    if (!response.ok) {
      throw new Error("Network response was not ok");
    }

    const data = await response.json();
    const count = data?.count ?? data?.visitors ?? data;
    if (typeof count === "number") {
      counterEl.textContent = count.toLocaleString();
    }
  } catch (error) {
    // Keep default placeholder and log error in console for debugging
    // eslint-disable-next-line no-console
    console.error("Failed to fetch visitor count:", error);
  }
}

fetchVisitorCount();

