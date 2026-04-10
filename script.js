async function getWeather() {
    const city = document.getElementById("city").value;

    const apiKey = "83c896dd8ac0ce009f2f2df709bca528"; 
    const url = `https://api.openweathermap.org/data/2.5/weather?q=${city}&appid=${apiKey}&units=metric`;

    try {
        const response = await fetch(url);
        const data = await response.json();

        document.getElementById("result").innerHTML =
            `<h3>${data.name}</h3>
             <p>🌡 Temp: ${data.main.temp}°C</p>
             <p>☁ Weather: ${data.weather[0].main}</p>`;
    } catch (error) {
        document.getElementById("result").innerText = "Error fetching data";
    }
}