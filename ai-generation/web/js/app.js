const form = document.querySelector("#image-form");
const promptInput = document.querySelector("#prompt");
const message = document.querySelector("#form-message");
const generateButton = document.querySelector("#generate-button");
const buttonLabel = generateButton.querySelector(".button-label");
const spinner = generateButton.querySelector(".spinner");
const modelSelect = document.querySelector("#model");

const requestJson = async (url, options = {}) => {
  const response = await fetch(url, options);
  const body = await response.json();
  if (!response.ok) throw new Error(body.detail || `Erreur HTTP ${response.status}`);
  return body;
};

const setBusy = (busy) => {
  generateButton.disabled = busy;
  buttonLabel.textContent = busy ? "Génération en cours..." : "Générer l’image";
  spinner.hidden = !busy;
};

const pollJob = async (jobId) => {
  while (true) {
    const job = await requestJson(`/api/jobs/${jobId}`);
    message.textContent = job.status === "queued" ? "En attente du GPU..." : "Génération locale en cours...";
    if (job.status === "completed") return requestJson(`/api/images/${job.result_id}`);
    if (job.status === "failed") throw new Error(job.error || "La génération a échoué.");
    await new Promise((resolve) => window.setTimeout(resolve, 1000));
  }
};

const showResult = (item) => {
  document.querySelector("#empty-result").hidden = true;
  const result = document.querySelector("#result");
  result.hidden = false;
  document.querySelector("#result-image").src = `${item.url}?t=${Date.now()}`;
  document.querySelector("#download-link").href = item.url;
  document.querySelector("#download-link").download = `${item.id}.png`;
  document.querySelector("#result-details").innerHTML = [
    ["Modèle", item.model],
    ["Seed", item.seed],
    ["Dimensions", `${item.width} × ${item.height}`],
    ["Temps", `${item.generationTime} s`],
  ].map(([key, value]) => `<div><dt>${key}</dt><dd>${value}</dd></div>`).join("");
};

const loadGallery = async () => {
  const items = await requestJson("/api/images");
  const gallery = document.querySelector("#gallery");
  gallery.replaceChildren(...items.slice(0, 12).map((item) => {
    const figure = document.createElement("figure");
    figure.className = "gallery-item";
    const image = document.createElement("img");
    image.src = item.url;
    image.alt = item.prompt;
    image.loading = "lazy";
    const caption = document.createElement("figcaption");
    const prompt = document.createElement("p");
    prompt.textContent = item.prompt;
    const details = document.createElement("span");
    details.textContent = `${item.width}×${item.height} · seed ${item.seed}`;
    caption.append(prompt, details);
    figure.append(image, caption);
    figure.addEventListener("click", () => showResult(item));
    return figure;
  }));
  document.querySelector("#empty-gallery").hidden = items.length > 0;
};

form.addEventListener("submit", async (event) => {
  event.preventDefault();
  message.classList.remove("error");
  setBusy(true);
  try {
    const seedValue = document.querySelector("#seed").value;
    const payload = {
      prompt: promptInput.value,
      width: Number(document.querySelector("#width").value),
      height: Number(document.querySelector("#height").value),
      steps: Number(document.querySelector("#steps").value),
      seed: seedValue ? Number(seedValue) : null,
      model: modelSelect.value,
    };
    const job = await requestJson("/api/images/generate", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(payload),
    });
    const result = await pollJob(job.id);
    showResult(result);
    await loadGallery();
    message.textContent = "Image générée localement.";
  } catch (error) {
    message.textContent = error.message;
    message.classList.add("error");
  } finally {
    setBusy(false);
  }
});

promptInput.addEventListener("input", () => {
  document.querySelector("#prompt-count").textContent = promptInput.value.length;
});

document.querySelectorAll(".tab").forEach((tab) => tab.addEventListener("click", () => {
  document.querySelectorAll(".tab").forEach((button) => button.classList.toggle("active", button === tab));
  document.querySelector("#image-panel").hidden = tab.dataset.tab !== "image";
  document.querySelector("#video-panel").hidden = tab.dataset.tab !== "video";
}));

document.querySelector("#refresh-gallery").addEventListener("click", loadGallery);

Promise.all([requestJson("/api/health"), requestJson("/api/models")])
  .then(([health, models]) => {
    document.querySelector("#health-status").textContent = health.status === "ok" ? "Moteur prêt" : "Indisponible";
    models.images.forEach((model) => modelSelect.add(new Option(`${model.name} · ${model.quantization} bits`, model.id)));
    return loadGallery();
  })
  .catch((error) => {
    document.querySelector("#health-status").textContent = "API indisponible";
    message.textContent = error.message;
    message.classList.add("error");
  });