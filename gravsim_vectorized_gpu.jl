using SimpleDirectMediaLayer
using SimpleDirectMediaLayer.LibSDL2

using Dates
using CUDA

DIMS = [800, 800]
DIMS_GPU = CuArray{Float16, 1}(DIMS)

FRAMES_PER_SECOND = 60;
TIMESTEP = 1.0 / FRAMES_PER_SECOND;

NUM_BODIES = 10_000 #100_000 #400_000 #8_000_000
BODY_WIDTH = 1
INITIAL_VEL_RANGE = 20.0

G = Float16(0.1)

pos = CuArray{Float16, 2}(undef, NUM_BODIES, 2)
vel = CuArray{Float16, 2}(undef, NUM_BODIES, 2)

function init_state()
    center = DIMS ./ 2.0
    window_size = DIMS ./ 4.0
    
    Threads.@threads for i = 1:NUM_BODIES
        pos[i, :] = (rand(Float16, 2) .- 0.5) .* window_size .+ center
        vel[i, :] = pos[i, :] ./ 100.0
    end
end

function initializing_sdl()
    SDL_GL_SetAttribute(SDL_GL_MULTISAMPLEBUFFERS, 16)
    SDL_GL_SetAttribute(SDL_GL_MULTISAMPLESAMPLES, 16)
    
    @assert SDL_Init(SDL_INIT_EVERYTHING) == 0 "error initializing SDL: $(unsafe_string(SDL_GetError()))"
    
    win = SDL_CreateWindow("Gravsim", SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, DIMS[1], DIMS[2], SDL_WINDOW_SHOWN)
    SDL_SetWindowResizable(win, SDL_FALSE)
    
    renderer = SDL_CreateRenderer(win, -1, SDL_RENDERER_ACCELERATED)# | SDL_RENDERER_PRESENTVSYNC)
    return win, renderer
end

function main()
    win, renderer = initializing_sdl()

    init_state()
    println(typeof(pos))
    
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
    # center = CuArray{Float16, 2}(DIMS ./ 2.0)
    center = DIMS_GPU ./ 2.0

    dp = pos .- reshape(center, (1, 2))
    d = sqrt.(sum(dp .^ 2, dims=2)) .+ 0.0001

    f = -G .* dp ./ d

    vel .+= f
    pos .+= vel
end

function draw(renderer)
    # draw center
    center = DIMS ./ 2.0
    center_x = Int(floor(center[1]))
    center_y = Int(floor(center[2]))
    SDL_SetRenderDrawColor(renderer, 255, 0, 0, 255)
    rect_ref = Ref(SDL_Rect(center_x, center_y, BODY_WIDTH, BODY_WIDTH))
    SDL_RenderFillRect(renderer, rect_ref)
    
    # copy the bodies back to cpu
    pos_cpu = Array(pos)

    # draw bodies
    # SDL_SetRenderDrawColor(renderer, 255, 255, 255, 255)
    # for i = 1:NUM_BODIES 
    #     @inbounds p = pos_cpu[i, :]
    #     x = Int(floor(p[1]))
    #     y = Int(floor(p[2]))
    #     SDL_RenderDrawPoint(renderer, x, y)
    #     # rect_ref = Ref(SDL_Rect(x, y, BODY_WIDTH, BODY_WIDTH))
    #     # SDL_RenderFillRect(renderer, rect_ref)
    # end

    # batch draw bodies
    SDL_SetRenderDrawColor(renderer, 255, 255, 255, 255)
    
    points = Vector{SDL_Point}(undef, NUM_BODIES)
    Threads.@threads for i = 1:NUM_BODIES 
        @inbounds p = pos_cpu[i, :]
        x = Int(floor(p[1]))
        y = Int(floor(p[2]))
        points[i] = SDL_Point(x, y)
    end
    SDL_RenderDrawPoints(renderer, points, NUM_BODIES)

end

main()


