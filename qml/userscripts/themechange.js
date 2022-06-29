

let select;
let firstRun = true;

function sleep (time) {
    return new Promise((resolve) => setTimeout(resolve, time));
  }

window.addEventListener('popstate', (e) => {
    if (/settings\/ariang$/.test(window.location.href)) {
        sleep(500).then(() => {
            select = document.querySelector('select[ng-model="context.settings.theme"');
            if (firstRun) {
                console.log('themeChangedMessage: ' + select.options.selectedIndex);
                select.addEventListener('change', () => console.log('themeChangedMessage: ' + select.options.selectedIndex));
                firstRun = true;
            }
        })
    }
    
})