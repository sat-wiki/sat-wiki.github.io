window.onload = function() {
    fetch('text/text.txt')
        .then(response => response.text())
        .then(data => {
            const content = document.getElementById('content');
            content.innerHTML = formatText(data);
        })
        .catch(error => console.error('Error loading text file:', error));
};

function formatText(text) {
    const paragraphs = text.split('\n');
    return paragraphs.map(paragraph => {
        const formattedParagraph = `　　${paragraph.trim()}`;
        return formattedParagraph;
    }).join('<br />');

}