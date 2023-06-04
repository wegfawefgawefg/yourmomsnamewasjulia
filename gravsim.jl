using SimpleDirectMediaLayer
using SimpleDirectMediaLayer.LibSDL2

using Dates

WINDOW_WIDTH = 800
WINDOW_HEIGHT = 800

FRAMES_PER_SECOND = 120;
TIMESTEP = 1.0 / FRAMES_PER_SECOND;

NUM_BODIES = 10000
BODY_WIDTH = 1
INITIAL_VEL_RANGE = 20.0

G = 0.1


struct Body
    x::Float32
    y::Float32

    vx::Float32
    vy::Float32
end

center_x = WINDOW_WIDTH / 2.0
center_y = WINDOW_HEIGHT / 2.0
bodies = Array{Body}(undef, NUM_BODIES)
for i = 1:NUM_BODIES
    x = (rand(Float32, 1)[1] - 0.5) * WINDOW_WIDTH / 4.0 + center_x
    y = (rand(Float32, 1)[1] - 0.5) * WINDOW_HEIGHT / 4.0 + center_y
    # vx = (rand(Float32, 1)[1] - 0.5) * INITIAL_VEL_RANGE
    # vy = (rand(Float32, 1)[1] - 0.5) * INITIAL_VEL_RANGE

    vx = x / 100.0
    vy = y / 100.0

    body = Body(x, y, vx, vy)
    bodies[i] = body
end

function initializing_sdl()
    SDL_GL_SetAttribute(SDL_GL_MULTISAMPLEBUFFERS, 16)
    SDL_GL_SetAttribute(SDL_GL_MULTISAMPLESAMPLES, 16)
    
    @assert SDL_Init(SDL_INIT_EVERYTHING) == 0 "error initializing SDL: $(unsafe_string(SDL_GetError()))"
    
    win = SDL_CreateWindow("Gravsim", SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, WINDOW_WIDTH, WINDOW_HEIGHT, SDL_WINDOW_SHOWN)
    SDL_SetWindowResizable(win, SDL_FALSE)
    
    renderer = SDL_CreateRenderer(win, -1, SDL_RENDERER_ACCELERATED)# | SDL_RENDERER_PRESENTVSYNC)
    return win, renderer
end

function main()
    win, renderer = initializing_sdl()
    
    time_since_last_update = 0.0;
    last_time = time()
    run = true  
    while run
        event_ref = Ref{SDL_Event}()
        while Bool(SDL_PollEvent(event_ref))
            evt = event_ref[]
            evt_ty = evt.type
            if evt_ty == SDL_QUIT
                run = false
                break
            elseif evt_ty == SDL_KEYDOWN
                scan_code = evt.key.keysym.scancode
                if scan_code == SDL_SCANCODE_ESCAPE || scan_code == SDL_SCANCODE_Q
                    run = false                     
                    break
                end
            end
        end

        t = time()
        dt = t - last_time
        time_since_last_update += dt
        while time_since_last_update > TIMESTEP
            time_since_last_update -= TIMESTEP
            step()
        end
        last_time = t

        SDL_SetRenderDrawColor(renderer, 0, 0, 0, 255)
        SDL_RenderClear(renderer)
        draw(renderer)
        SDL_RenderPresent(renderer)
    end

    SDL_DestroyRenderer(renderer)
    SDL_DestroyWindow(win)
    SDL_Quit()
end

"""This works if you make the render target an intermediate texture that supports transparency. 
    Legwork hasn't been done but its there
"""
function semi_clear(renderer)    
    SDL_SetRenderDrawColor(renderer, 0, 0, 0, 1)
    rect_ref = Ref(SDL_Rect(0, 0, WINDOW_WIDTH, WINDOW_HEIGHT))
    SDL_RenderFillRect(renderer, rect_ref)
end

function step()
    center_x = Float32(WINDOW_WIDTH / 2)
    center_y = Float32(WINDOW_HEIGHT / 2)

    # update positions
    Threads.@threads for i = 1:NUM_BODIES
        @inbounds body = bodies[i]

        dx = body.x - center_x
        dy = body.y - center_y
        d = sqrt(dx * dx + dy * dy)

        fx = -G * dx / d
        fy = -G * dy / d

        vx = body.vx + fx
        vy = body.vy + fy

        x = body.x + vx
        y = body.y + vy

        new_body = Body(x, y, vx, vy)

        bodies[i] = new_body
    end
end

function draw(renderer)
    # draw center
    center_x = WINDOW_WIDTH / 2
    center_y = WINDOW_HEIGHT / 2
    SDL_SetRenderDrawColor(renderer, 255, 0, 0, 255)
    rect_ref = Ref(SDL_Rect(center_x, center_y, BODY_WIDTH, BODY_WIDTH))
    SDL_RenderFillRect(renderer, rect_ref)
    
    # draw bodies
    SDL_SetRenderDrawColor(renderer, 255, 255, 255, 255)
    for i = 1:NUM_BODIES 
        @inbounds body = bodies[i]
        x = Int(floor(body.x))
        y = Int(floor(body.y))
        SDL_RenderDrawPoint(renderer, x, y)
        # rect_ref = Ref(SDL_Rect(x, y, BODY_WIDTH, BODY_WIDTH))
        # SDL_RenderFillRect(renderer, rect_ref)
    end

end

main()


