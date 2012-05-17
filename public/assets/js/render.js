// render.js

$(document).ready(function() {
    tex_form = $('#tex-form');
    tex_box = $('#tex-form-content');
    tex_image = $('#tex-image');

    // form click event handler
    tex_form.submit(function (e){ 
        e.preventDefault();

        $.post("/render", {
            content: tex_box.val(),
        }, function(r) { 
            $('#tex-image')
                .attr('src', r.image_url)
                .attr('alt', r.content); 
        });
    });
});
