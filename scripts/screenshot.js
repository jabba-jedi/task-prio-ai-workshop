import { chromium } from '@playwright/test';

async function takeScreenshot() {
  console.log('🚀 Launching browser...');
  const browser = await chromium.launch();
  const page = await browser.newPage();
  
  console.log('📱 Navigating to http://localhost:5173...');
  await page.goto('http://localhost:5173');
  
  // Wait for the page to load
  await page.waitForLoadState('networkidle');
  
  // Take full page screenshot
  console.log('📸 Taking full page screenshot...');
  await page.screenshot({ 
    path: 'screenshots/main-page-full.png',
    fullPage: true 
  });
  
  // Take viewport screenshot
  console.log('📸 Taking viewport screenshot...');
  await page.screenshot({ 
    path: 'screenshots/main-page-viewport.png'
  });
  
  // Take screenshot with example text entered
  console.log('✍️  Filling in example task...');
  await page.fill('#task-input', 'Fix the bug in the login form');
  await page.screenshot({ 
    path: 'screenshots/main-page-with-input.png',
    fullPage: true 
  });
  
  // Submit and take screenshot of results
  console.log('🔍 Submitting task and capturing results...');
  await page.click('button[type="submit"]');
  await page.waitForSelector('#results-container:not(.hidden)', { timeout: 5000 });
  await page.screenshot({ 
    path: 'screenshots/main-page-with-results.png',
    fullPage: true 
  });
  
  await browser.close();
  
  console.log('✅ Screenshots saved to screenshots/ directory!');
  console.log('   - main-page-full.png (full page)');
  console.log('   - main-page-viewport.png (viewport only)');
  console.log('   - main-page-with-input.png (with text input)');
  console.log('   - main-page-with-results.png (with analysis results)');
}

takeScreenshot().catch(error => {
  console.error('❌ Error taking screenshot:', error);
  process.exit(1);
});

