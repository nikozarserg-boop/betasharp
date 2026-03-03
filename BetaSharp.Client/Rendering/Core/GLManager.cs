using Vuldrid;

namespace BetaSharp.Client.Rendering.Core;

/// <summary>
/// Central manager for Vuldrid graphics resources.
/// Provides the GraphicsDevice, CommandList, and the emulated GL interface.
/// </summary>
public class GLManager
{
    public static IGL GL { get; private set; }
    public static GraphicsDevice Device { get; private set; }
    public static ResourceFactory Factory { get; private set; }
    public static CommandList CommandList { get; private set; }
    public static Framebuffer SwapchainFramebuffer => Device.MainSwapchain.Framebuffer;

    private static bool s_isDisposed = false;

    public static void Init(GraphicsDevice device)
    {
        if (Device != null) return;
        s_isDisposed = false;

        Device = device;
        Factory = device.ResourceFactory;
        CommandList = Factory.CreateCommandList();
        GL = new OpenGL.EmulatedGL(device);
    }

    /// <summary>
    /// Begin recording commands for a new frame.
    /// </summary>
    public static void BeginFrame()
    {
        if (s_isDisposed) return;
        GPUResourceCollector.Update();
        GL.NewFrame();
        CommandList.Begin();
        CommandList.SetFramebuffer(SwapchainFramebuffer);
    }

    /// <summary>
    /// End recording and submit commands, then present.
    /// </summary>
    public static void EndFrame()
    {
        if (s_isDisposed) return;
        CommandList.End();
        Device.SubmitCommands(CommandList);
    }

    public static void Dispose()
    {
        if (s_isDisposed) return;
        s_isDisposed = true;

        (GL as IDisposable)?.Dispose();
        CommandList?.Dispose();

        GL = null!;
        CommandList = null!;
        Device = null!;
        Factory = null!;

        GPUResourceCollector.Flush();
    }
}
