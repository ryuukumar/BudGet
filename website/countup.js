
// 
// BudGet v1.0.3
// (c) Aditya Kumar, 2023
// Some rights reserved.
// 
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
// 
// This code is NOT intended to work on any systems apart from mine,
// so do NOT expect active support from me.
// 
// Do NOT redistribute this program without first consulting with
// the original developer, i.e. me.
// 

function formatNumber(number) {
  var ret = String("");
  var num = String(number);

  for (i = 0; i < num.length; i++) {
    if (!(i % 3) && i != 0) {
      ret = "," + ret;
    }
    ret = num[num.length - i - 1] + ret;
  }

  return ret;
}

// How long you want the animation to take, in ms
const animationDuration = 2000;
// Calculate how long each ‘frame’ should last if we want to update the animation 60 times per second
const frameDuration = 1000 / 60;
// Use that to calculate how many frames we need to complete the animation
const totalFrames = Math.round(animationDuration / frameDuration);
// An ease-out function that slows the count as it progresses
const easeOutQuad = (t) => t * (2 - t);

// The animation function, which takes an Element
const animateCountUp = (el) => {
  let frame = 0;
  const countTo = parseInt(el.innerHTML, 10);
  // Start the animation running 60 times per second
  const counter = setInterval(() => {
    frame++;
    // Calculate our progress as a value between 0 and 1
    // Pass that value to our easing function to get our
    // progress on a curve
    const progress = easeOutQuad(frame / totalFrames);
    // Use the progress value to calculate the current count
    const currentCount = Math.round(countTo * progress);

    // If the current count has changed, update the element
    if (parseInt(el.innerHTML, 10) !== currentCount) {
      el.innerHTML = formatNumber(currentCount);
    }

    // If we’ve reached our last frame, stop the animation
    if (frame === totalFrames) {
      document.getElementById("yearspend").innerHTML = formatNumber(
        yeartotal.toFixed(0)
      );
      clearInterval(counter);
    }
  }, frameDuration);
};

let isRunning = false;
let hasPlayed = false;

// Run the animation on all elements with a class of ‘countup’
const runAnimations = (intersectionRatio) => {
  if (isRunning) return;
  const bgbody = document.getElementsByClassName("body-inside")[0];
  bgbody.style.backdropFilter = "blur(" + String(5*intersectionRatio) + "px)";
  console.log("blur(" + String(5*intersectionRatio) + "px)");
  if (intersectionRatio != 1) return;
  if (hasPlayed) return;
  isRunning = true;
  const countupEls = document.querySelectorAll(".countup");
  countupEls.forEach(animateCountUp);
  isRunning = false;
  hasPlayed = true;
};

function buildThresholdList() {
  let thresholds = [];
  let numSteps = 20;

  for (let i=1.0; i<=numSteps; i++) {
    let ratio = i/numSteps;
    thresholds.push(ratio);
  }

  thresholds.push(0);
  return thresholds;
}


let options = {
  root: document.querySelector("#scrollArea"),
  rootMargin: "0px",
  threshold: buildThresholdList()
};

let callback = (entries, observer) => {
    document.getElementById("yearspend").innerHTML = yeartotal.toFixed(2);
    runAnimations(entries[0].intersectionRatio);
    document.getElementById("yearspend").innerHTML = formatNumber(
      yeartotal.toFixed(0)
    );
};

let observer = new IntersectionObserver(callback, options);

let target = document.querySelector("#yearspend");
observer.observe(target);
