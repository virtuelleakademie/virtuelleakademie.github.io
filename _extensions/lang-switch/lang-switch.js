// lang-switch.js
// Injects language switcher into Quarto navbar tools

document.addEventListener("DOMContentLoaded", function() {
  // Read configuration from injected script tag
  const configEl = document.getElementById("lang-switch-config");
  if (!configEl) {
    console.warn("lang-switch: No configuration found");
    return;
  }

  let config;
  try {
    config = JSON.parse(configEl.textContent);
  } catch (e) {
    console.error("lang-switch: Failed to parse configuration", e);
    return;
  }

  // Find the navbar tools container (where GitHub icon, etc. are)
  const toolsContainer = document.querySelector(".quarto-navbar-tools");
  if (toolsContainer) {
    insertToolsSwitcher(toolsContainer, config);
    return;
  }

  // Fallback: try the right navbar
  const rightNav = document.querySelector(".navbar-nav:not(.navbar-nav-scroll)");
  if (rightNav) {
    insertNavSwitcher(rightNav, config);
    return;
  }

  console.warn("lang-switch: No suitable navbar container found");
});

function insertToolsSwitcher(container, config) {
  // Create language switcher as a navbar tool (dropdown style)
  const switcher = document.createElement("div");
  switcher.className = "nav-item dropdown lang-switch-tool";

  switcher.innerHTML = `
    <a class="nav-link dropdown-toggle" href="#" role="button"
       data-bs-toggle="dropdown" aria-expanded="false" aria-label="Select language">
      <i class="bi bi-translate"></i>
      <span class="lang-switch-current">${config.currentLang.toUpperCase()}</span>
    </a>
    <ul class="dropdown-menu dropdown-menu-end">
      ${config.languages.map(lang => `
        <li>
          <a class="dropdown-item ${lang.code === config.currentLang ? 'active' : ''}"
             href="#"
             data-lang="${lang.code}">
            ${lang.name}
          </a>
        </li>
      `).join('')}
    </ul>
  `;

  // Insert at the beginning of tools (before other icons)
  container.insertBefore(switcher, container.firstChild);

  // Add click handlers
  addClickHandlers(switcher, config);
}

function insertNavSwitcher(navElement, config) {
  // Fallback: Create language switcher as nav item
  const switcher = document.createElement("li");
  switcher.className = "nav-item dropdown lang-switch-dropdown";

  switcher.innerHTML = `
    <a class="nav-link dropdown-toggle" href="#" role="button"
       data-bs-toggle="dropdown" aria-expanded="false">
      <i class="bi bi-translate"></i>
      <span class="lang-switch-current">${config.currentLang.toUpperCase()}</span>
    </a>
    <ul class="dropdown-menu dropdown-menu-end">
      ${config.languages.map(lang => `
        <li>
          <a class="dropdown-item ${lang.code === config.currentLang ? 'active' : ''}"
             href="#"
             data-lang="${lang.code}">
            ${lang.name}
          </a>
        </li>
      `).join('')}
    </ul>
  `;

  navElement.appendChild(switcher);

  // Add click handlers
  addClickHandlers(switcher, config);
}

function addClickHandlers(switcher, config) {
  const langLinks = switcher.querySelectorAll("[data-lang]");
  langLinks.forEach(link => {
    link.addEventListener("click", function(e) {
      e.preventDefault();
      const targetLang = this.getAttribute("data-lang");
      handleLanguageSwitch(targetLang, config);
    });
  });
}

function handleLanguageSwitch(targetLang, config) {
  // If same language, do nothing
  if (targetLang === config.currentLang) {
    return;
  }

  // If explicit translation URL provided, navigate to it
  if (config.translationUrl) {
    window.location.href = config.translationUrl;
    return;
  }

  // If no translation available, show toast
  if (!config.hasTranslation) {
    showTranslationUnavailable();
    return;
  }

  // Calculate target URL based on convention
  const url = getTranslationUrl(targetLang, config);
  if (url && url !== "#") {
    window.location.href = url;
  }
}

function getTranslationUrl(targetLang, config) {
  const path = window.location.pathname;
  const defaultLang = config.defaultLang;

  if (targetLang === defaultLang) {
    // Remove language prefix (e.g., /de/teaching/ -> /teaching/)
    return path.replace(/^\/de\//, '/');
  } else {
    // Add language prefix (e.g., /teaching/ -> /de/teaching/)
    const cleanPath = path.replace(/^\/de\//, '/');
    return '/' + targetLang + cleanPath;
  }
}

function showTranslationUnavailable() {
  // Remove existing toast if any
  const existingToast = document.querySelector(".lang-switch-toast");
  if (existingToast) {
    existingToast.remove();
  }

  // Create toast notification
  const toast = document.createElement("div");
  toast.className = "lang-switch-toast";
  toast.textContent = "Translation unavailable";
  toast.setAttribute("role", "alert");
  toast.setAttribute("aria-live", "polite");

  document.body.appendChild(toast);

  // Remove after animation completes
  setTimeout(() => {
    if (toast.parentNode) {
      toast.remove();
    }
  }, 3000);
}
