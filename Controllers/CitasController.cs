using ClinicaAPI.DTOs;
using ClinicaAPI.Models;
using ClinicaAPI.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace ClinicaAPI.Controllers;

[ApiController]
[Route("api/[controller]")]
[Produces("application/json")]
public class CitasController : ControllerBase
{
    private readonly ICitaService _citaService;

    public CitasController(ICitaService citaService)
    {
        _citaService = citaService;
    }

    /// <summary>Obtiene todas las citas médicas</summary>
    [HttpGet]
    [ProducesResponseType(typeof(IEnumerable<CitaResponseDto>), StatusCodes.Status200OK)]
    public IActionResult ObtenerTodas()
    {
        var citas = _citaService.ObtenerTodas();
        return Ok(new { success = true, data = citas });
    }

    /// <summary>Obtiene una cita por su ID</summary>
    [HttpGet("{id:int}")]
    [ProducesResponseType(typeof(CitaResponseDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public IActionResult ObtenerPorId(int id)
    {
        var cita = _citaService.ObtenerPorId(id);
        return Ok(new { success = true, data = cita });
    }

    /// <summary>Obtiene las citas de un paciente específico</summary>
    [HttpGet("paciente/{pacienteId:int}")]
    [ProducesResponseType(typeof(IEnumerable<CitaResponseDto>), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public IActionResult ObtenerPorPaciente(int pacienteId)
    {
        var citas = _citaService.ObtenerPorPaciente(pacienteId);
        return Ok(new { success = true, data = citas });
    }

    /// <summary>Obtiene las citas asignadas a un médico específico</summary>
    [HttpGet("medico/{medicoId:int}")]
    [ProducesResponseType(typeof(IEnumerable<CitaResponseDto>), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public IActionResult ObtenerPorMedico(int medicoId)
    {
        var citas = _citaService.ObtenerPorMedico(medicoId);
        return Ok(new { success = true, data = citas });
    }

    /// <summary>Filtra citas por estado (Pendiente, Confirmada, Cancelada, Completada)</summary>
    [HttpGet("estado/{estado}")]
    [ProducesResponseType(typeof(IEnumerable<CitaResponseDto>), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public IActionResult ObtenerPorEstado(string estado)
    {
        if (!Enum.TryParse<EstadoCita>(estado, true, out var estadoEnum))
            return BadRequest(new { success = false, message = $"Estado '{estado}' no válido. Valores aceptados: Pendiente, Confirmada, Cancelada, Completada" });

        var citas = _citaService.ObtenerPorEstado(estadoEnum);
        return Ok(new { success = true, data = citas });
    }

    /// <summary>Registra una nueva cita médica</summary>
    [HttpPost]
    [ProducesResponseType(typeof(CitaResponseDto), StatusCodes.Status201Created)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public IActionResult Crear([FromBody] CitaCreateDto dto)
    {
        var cita = _citaService.Crear(dto);
        return CreatedAtAction(nameof(ObtenerPorId), new { id = cita.Id },
            new { success = true, message = "Cita registrada exitosamente", data = cita });
    }

    /// <summary>Actualiza una cita médica existente</summary>
    [HttpPut("{id:int}")]
    [ProducesResponseType(typeof(CitaResponseDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public IActionResult Actualizar(int id, [FromBody] CitaUpdateDto dto)
    {
        var cita = _citaService.Actualizar(id, dto);
        return Ok(new { success = true, message = "Cita actualizada exitosamente", data = cita });
    }

    /// <summary>Cancela una cita médica</summary>
    [HttpPatch("{id:int}/cancelar")]
    [ProducesResponseType(typeof(CitaResponseDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public IActionResult Cancelar(int id)
    {
        var cita = _citaService.Cancelar(id);
        return Ok(new { success = true, message = "Cita cancelada exitosamente", data = cita });
    }

    /// <summary>Elimina una cita médica por su ID</summary>
    [HttpDelete("{id:int}")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public IActionResult Eliminar(int id)
    {
        _citaService.Eliminar(id);
        return Ok(new { success = true, message = $"Cita con ID {id} eliminada exitosamente" });
    }
}
