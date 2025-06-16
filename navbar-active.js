<script>
// Generic navbar highlighting based on current URL
document.addEventListener('DOMContentLoaded', function() {
  const navLinks = document.querySelectorAll('.navbar-nav .nav-link');
  const currentPath = window.location.pathname;
  
  navLinks.forEach(link => {
    // Get the link's path
    const linkPath = new URL(link.href, window.location.origin).pathname;
    
    // Normalize paths (remove trailing slashes, index.html)
    const normalizedCurrent = currentPath.replace(/\/$/, '').replace(/\/index\.html$/, '');
    const normalizedLink = linkPath.replace(/\/$/, '').replace(/\/index\.html$/, '');
    
    // Check if we're in this section (current path starts with link path)
    if (normalizedCurrent.startsWith(normalizedLink) && normalizedLink !== '') {
      link.classList.add('active');
    }
  });
});
</script>